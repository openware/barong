# frozen_string_literal: true

module API::V2
  module Resource
    class Users < Grape::API
      helpers do
        def password_error!(options = {})
          options[:topic] = 'password'
          record_error!(options)
        end

        def validate_topic!(topic)
          unless %w[all session otp password].include?(topic)
            error!({ errors: ['resource.user.wrong_topic'] }, 422)
          end
        end
      end

      resource :users do
        desc 'Returns current user'
        get '/me' do
          present current_user, with: API::V2::Entities::User
          status(200)
        end

        desc 'Returns user activity'
        params do
          requires :topic, type: String,
                              allow_blank: false,
                              desc: 'Topic of user activity. Allowed: [all, password, session, otp]'
          optional :page,     type: Integer, default: 1,   integer_gt_zero: true, desc: 'Page number (defaults to 1).'
          optional :limit,    type: Integer, default: 100, range: 1..1000, desc: 'Number of withdraws per page (defaults to 100, maximum is 1000).'
        end
        get '/activity/:topic' do
          validate_topic!(params[:topic])
          data = current_user.activities
          data = data.where(topic: params[:topic]) if params[:topic] != 'all'

          error!({ errors: ['resource.user.no_activity'] }, 422) unless data.present?

          present paginate(data)
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
        put '/password' do
          unless params[:new_password] == params[:confirm_password]
            password_error!(reason: 'New passwords don\'t match',
              error_code: 422, user: current_user.id, action: 'password change', error_text: 'doesnt_match')
          end

          unless password_valid?(params[:old_password])
            password_error!(reason: 'Previous password is not correct',
              error_code: 400, user: current_user.id, action: 'password change', error_text: 'prev_pass_not_correct')
          end

          if params[:old_password] == params[:new_password]
            password_error!(reason: 'New password cant be the same, as old one',
              error_code: 400, user: current_user.id, action: 'password change', error_text: 'no_change_provided')
          end

          unless current_user.update(password: params[:new_password])
            error_note = { reason: current_user.errors.full_messages.to_sentence }.to_json
            activity_record(user: current_user.id, action: 'password change',
                            result: 'failed', topic: 'password', data: error_note)
            # FIXME: active record validation
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
