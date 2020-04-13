# frozen_string_literal: true

module API::V2
  module Resource
    class Users < Grape::API
      helpers ::API::V2::NamedParams
      helpers do
        def password_error!(options = {})
          options[:topic] = 'password'
          record_error!(options)
        end

        def validate_topic!(topic)
          unless %w[all session otp password account].include?(topic)
            error!({ errors: ['resource.user.wrong_topic'] }, 422)
          end
        end

        def verify_otp!
          error!({ errors: ['resource.user.missing_otp_code'] }, 422) if params[:otp_code].nil?

          error!({ errors: ['resource.user.empty_otp_code'] }, 422) if params[:otp_code].empty?

          error!({ errors: ['resource.user.invalid_otp'] }, 422) unless TOTPService.validate?(current_user.uid, params[:otp_code])
        end
      end

      resource :users do
        desc 'Returns current user'
        get '/me' do
          present current_user, with: API::V2::Entities::UserWithFullInfo
          status(200)
        end

        desc 'Updates current user data field'
        params do
          requires :data, type: String, allow_blank: false, desc: 'Any additional key: value pairs in json string format'
        end
        put '/me' do
          code_error!(current_user.errors.details, 422) unless current_user.update(data: params[:data])

          present current_user, with: API::V2::Entities::UserWithFullInfo
          status(201)
        end

        desc 'Blocks current user'
        params do
          requires :password, type: String, allow_blank: false, desc: 'Account password'
          optional :otp_code, type: String, allow_blank: false, desc: 'Code from Google Authenticator'
        end
        delete '/me' do
          error!({ errors: ['resource.user.invalid_password'] }, 422) unless password_valid?(params[:password])

          verify_otp! if current_user.otp

          current_user.labels.create(key: 'delete', value: 'by_user', scope: 'private')
          EventAPI.notify(
            'system.user.account.deleted',
            record: { user: current_user.as_json_for_event_api }
          )

          status(200)
        end

        desc 'Returns user activity'
        params do
          requires :topic,
                   type: String,
                   allow_blank: { value: false, message: 'resource.user.empty_topic' },
                   desc: 'Topic of user activity. Allowed: [all, password, session, otp]'
          use :pagination_filters
        end
        get '/activity/:topic' do
          validate_topic!(params[:topic])
          data = current_user.activities.order('id DESC')
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
          requires :old_password,
                   type: String,
                   allow_blank: false,
                   desc: 'Previous account password'
          requires :new_password,
                   type: String,
                   allow_blank: false,
                   desc: 'User password'
          requires :confirm_password,
                   type: String,
                   allow_blank: false,
                   desc: 'User password'
          optional :lang,
                   type: String,
                   desc: 'Language in iso-2 format'
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
            code_error!(current_user.errors.details, 422)
          end

          activity_record(user: current_user.id, action: 'password change', result: 'succeed', topic: 'password')

          language = params[:lang].to_s.empty? ? 'EN' : params[:lang].upcase

          EventAPI.notify('system.user.password.change',
                          record: {
                            user: current_user.as_json_for_event_api,
                            language: language,
                            domain: Barong::App.config.domain
                          })
          status 201
        end
      end
    end
  end
end
