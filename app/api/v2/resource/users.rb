# frozen_string_literal: true

module API::V2
  module Resource
    class Users < Grape::API
      helpers do
        def password_error!(options = {})
          options[:topic] = 'password'
          record_error!(options)
        end
      end

      resource :users do
        desc 'Returns current user'
        get '/me' do
          current_user.attributes.except('password_digest')
        end

        desc 'Returns user activity'
        params do
          requires :topic, type: String,
                              allow_blank: false,
                              desc: 'Topic of user activity. Allowed: [all, password, session, otp]'
        end
        get '/activity/:topic' do
          data = current_user.activities
          data = data.where(topic: params[:topic]) if params[:topic] != 'all'
          error!('No activity recorded or wrong topic') unless data.present?
          data
        end

        desc 'Sets new account password',
        success: { code: 201, message: 'Changes password' },
        failure: [
          { code: 400, message: 'Required params are empty' },
          { code: 404, message: 'Record is not found' },
          { code: 422, message: 'Validation errors' }
        ]
        params do
          requires :old_password, type: String,
                                          desc: 'Previous account password',
                                          allow_blank: false
          requires :new_password, type: String,
                              desc: 'User password',
                              allow_blank: false
          requires :confirm_password, type: String,
                              desc: 'User password',
                              allow_blank: false
        end
        post '/password' do
          unless params[:new_password] == params[:confirm_password]
            password_error!(reason: 'New passwords don\'t match',
              error_code: 422, user: current_user.id, action: 'password change')
          end

          unless password_valid?(params[:old_password])
            password_error!(reason: 'Previous password is not correct',
              error_code: 400, user: current_user.id, action: 'password change')
          end

          if params[:old_password] == params[:new_password]
            password_error!(reason: 'New password cant be the same, as old one',
              error_code: 400, user: current_user.id, action: 'password change')
          end

          unless current_user.update(password: params[:new_password])
            error_note = { reason: current_user.errors.full_messages.to_sentence }.to_json
            activity_record(user: current_user.id, action: 'password change',
                            result: 'failed', topic: 'password', data: error_note)
            error!(current_user.errors.full_messages, 422)
          end

          activity_record(user: current_user.id, action: 'password change', result: 'succeed', topic: 'password')

          EventAPI.notify('system.user.password.change', current_user.as_json_for_event_api)
          status 201
        end
      end
    end
  end
end
