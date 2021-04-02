# frozen_string_literal: true

require_dependency 'barong/jwt'

module API::V2
  module Identity
    class Users < Grape::API
      helpers do
        def parse_refid!
          error!({ errors: ['identity.user.invalid_referral_format'] }, 422) unless params[:refid].start_with?(Barong::App.config.uid_prefix.upcase)
          user = User.find_by_uid(params[:refid])
          error!({ errors: ['identity.user.referral_doesnt_exist'] }, 422) if user.nil?

          user.id
        end
      end

      desc 'User related routes'
      resource :users do
        desc 'Creates new whitelist restriction',
          failure: [
            { code: 400, message: 'Required params are missing' },
            { code: 422, message: 'Validation errors' }
          ],
          success: { code: 200, message: 'Whitelist restriction was created' }
        params do
          requires :whitelink_token,
                   type: String,
                   allow_blank: false
        end
        post '/access' do
          if Rails.cache.read(params[:whitelink_token]) == 'active'
            restriction = Restriction.new(
              category: 'whitelist',
              scope: 'ip',
              value: remote_ip,
              state: 'enabled'
            )

            code_error!(restriction.errors.details, 422) unless restriction.save
            Rails.cache.delete('restrictions')
          else
            error!({ errors: ['identity.user.access.invalid_token'] }, 422)
          end
        end

        desc 'Creates new user',
          success: API::V2::Entities::UserWithFullInfo,
          failure: [
            { code: 400, message: 'Required params are missing' },
            { code: 422, message: 'Validation errors' }
          ]
        params do
          requires :email,
                   type: String,
                   allow_blank: false,
                   desc: 'User Email'
          requires :password,
                   type: String,
                   allow_blank: false,
                   desc: 'User Password'
          optional :username,
                   type: String,
                   desc: 'User Username'
          optional :refid,
                   type: String,
                   desc: 'Referral uid'
          optional :captcha_response,
                   types: [String, Hash],
                   desc: 'Response from captcha widget'
          optional :data,
                   type: String,
                   desc: 'Any additional key: value pairs in json string format'
        end
        post do
          verify_captcha!(response: params['captcha_response'], endpoint: 'user_create')

          declared_params = declared(params, include_missing: false)
          user_params = declared_params.slice('email', 'password', 'data', 'username')

          user_params[:referral_id] = parse_refid! unless params[:refid].nil?

          user = User.new(user_params)
          code_error!(user.errors.details, 422) unless user.save

          activity_record(user: user.id, action: 'signup', result: 'succeed', topic: 'account')

          # Creates superadmin user in first platform registration
          if Barong::App.config.first_registration_superadmin && User.count == 1
            user.update(role: 'superadmin', state: 'active')
            user.labels.create(key: 'email', value: 'verified', scope: 'private')
          else
            publish_confirmation(user, Barong::App.config.domain)
          end

          csrf_token = open_session(user)

          present user, with: API::V2::Entities::UserWithFullInfo, csrf_token: csrf_token
        end

        desc 'Register Geetest captcha'
        get '/register_geetest' do
          CaptchaService::GeetestVerifier.new.register
        end

        namespace :email do
          desc 'Send confirmations instructions',
            success: { code: 201, message: 'Generated verification code' },
            failure: [
              { code: 400, message: 'Required params are missing' },
              { code: 422, message: 'Validation errors' }
            ]
          params do
            requires :email,
                     type: String,
                     allow_blank: false,
                     desc: 'Account email'
            optional :captcha_response,
                     types: [String, Hash],
                     desc: 'Response from captcha widget'
          end
          post '/generate_code' do
            verify_captcha!(response: params['captcha_response'], endpoint: 'email_confirmation')

            current_user = User.find_by_email(params[:email])

            if current_user.nil? || current_user.active?
              return status 201
            end

            publish_confirmation(current_user, Barong::App.config.domain)
            status 201
          end

          desc 'Confirms an account',
            success: API::V2::Entities::UserWithFullInfo,
            failure: [
              { code: 400, message: 'Required params are missing' },
              { code: 422, message: 'Validation errors' }
            ]
          params do
            requires :token,
                     type: String,
                     allow_blank: false,
                     desc: 'Token from email'
          end
          post '/confirm_code' do
            payload = codec.decode_and_verify(
              params[:token],
              pub_key: Barong::App.config.keystore.public_key,
              sub: 'confirmation'
            )
            current_user = User.find_by_email(payload[:email])

            if current_user.nil? || current_user.active?
              error!({ errors: ['identity.user.active_or_doesnt_exist'] }, 422)
            end

            current_user.labels.create!(key: 'email', value: 'verified', scope: 'private') if token_uniq?(payload[:jti])

            csrf_token = open_session(current_user)

            EventAPI.notify('system.user.email.confirmed',
                            record: {
                              user: current_user.as_json_for_event_api,
                              domain: Barong::App.config.domain
                            })

            present current_user, with: API::V2::Entities::UserWithFullInfo, csrf_token: csrf_token
          end
        end

        namespace :password do
          desc 'Send password reset instructions',
            success: { code: 201, message: 'Generated password reset code' },
            failure: [
              { code: 400, message: 'Required params are missing' },
              { code: 422, message: 'Validation errors' },
              { code: 404, message: 'User doesn\'t exist'}
            ]
          params do
            requires :email,
                     type: String,
                     message: 'identity.user.missing_email',
                     allow_blank: false,
                     desc: 'Account email'
            optional :captcha_response,
                     types: [String, Hash],
                     desc: 'Response from captcha widget'
          end

          post '/generate_code' do
            verify_captcha!(response: params['captcha_response'], endpoint: 'password_reset')

            current_user = User.find_by_email(params[:email])

            return status 201 if current_user.nil?

            reset_token = SecureRandom.hex(10)
            token = codec.encode(sub: 'reset', email: params[:email], uid: current_user.uid, reset_token: reset_token)
            # save reset_password_id in cache to validate as latest requested
            Rails.cache.write("reset_password_#{params[:email]}", reset_token, expires_in: Barong::App.config.jwt_expire_time.seconds)

            activity_record(user: current_user.id, action: 'request password reset', result: 'succeed', topic: 'password')

            EventAPI.notify('system.user.password.reset.token',
                            record: {
                              user: current_user.as_json_for_event_api,
                              domain: Barong::App.config.domain,
                              token: token
                            })

            status 201
          end

          desc 'Sets new account password',
            success: { code: 201, message: 'Resets password' },
            failure: [
              { code: 400, message: 'Required params are empty' },
              { code: 404, message: 'Record is not found' },
              { code: 422, message: 'Validation errors' }
            ]
          params do
            requires :reset_password_token,
                     type: String,
                     message: 'identity.user.missing_pass_token',
                     allow_blank: false,
                     desc: 'Token from email'
            requires :password,
                     type: String,
                     message: 'identity.user.missing_password',
                     allow_blank: false,
                     desc: 'User password'
            requires :confirm_password,
                     type: String,
                     message: 'identity.user.missing_confirm_password',
                     allow_blank: false,
                     desc: 'User password'
          end
          post '/confirm_code' do
            unless params[:password] == params[:confirm_password]
              error!({ errors: ['identity.user.passwords_doesnt_match'] }, 422)
            end

            payload = codec.decode_and_verify(
              params[:reset_password_token],
              pub_key: Barong::App.config.keystore.public_key, sub: 'reset'
            )

            # check if reset_password token is latest requested and was not used before
            if Rails.cache.read("reset_password_#{payload[:email]}") != payload[:reset_token] || Rails.cache.read(payload[:jti]) == 'utilized'
              error!({ errors: ['identity.user.utilized_token'] }, 422)
            end

            current_user = User.find_by_email(payload[:email])

            unless current_user.update(password: params[:password])
              error_note = { reason: current_user.errors.full_messages.to_sentence }.to_json
              activity_record(user: current_user.id, action: 'password reset',
                              result: 'failed', topic: 'password', data: error_note)
              code_error!(current_user.errors.details, 422)
            end

            # remove latest token id cache record
            Rails.cache.delete("reset_password_#{params[:email]}")
            # invalidate token used
            Rails.cache.write(payload[:jti], 'utilized', expires_in: Barong::App.config.jwt_expire_time.seconds)

            activity_record(user: current_user.id, action: 'password reset', result: 'succeed', topic: 'password')

            EventAPI.notify('system.user.password.reset',
                            record: {
                              user: current_user.as_json_for_event_api,
                              domain: Barong::App.config.domain
                            })

            # Invalidate all old user session
            Barong::RedisSession.invalidate_all(current_user.uid)

            status 201
          end
        end
      end
    end
  end
end
