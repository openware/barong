# frozen_string_literal: true

require_dependency 'barong/jwt'

module API::V2
  module Identity
    class Sessions < Grape::API
      helpers do
        def get_user(email)
          user = User.find_by(email: email)
          error!({ errors: ['identity.session.invalid_params'] }, 401) unless user

          if user.state == 'banned'
            login_error!(reason: 'Your account is banned', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'banned')
          end

          if user.state == 'deleted'
            login_error!(reason: 'Your account is deleted', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'deleted')
          end

          # if user is not active or pending, then return 401
          unless user.state.in?(%w[active pending])
            login_error!(reason: 'Your account is not active', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'not_active')
          end
          user
        end
      end

      desc 'Session related routes'
      resource :sessions do
        desc 'Start a new session',
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 404, message: 'Record is not found' }
             ]
        params do
          requires :email
          requires :password
          optional :captcha_response,
                   types: { value: [String, Hash], message: 'identity.session.invalid_captcha_format' },
                   desc: 'Response from captcha widget'
          optional :otp_code,
                   type: String,
                   desc: 'Code from Google Authenticator'
        end
        post do
          error!({ errors: ['identity.session.endpoint_not_enabled'] }, 422) unless Barong::App.config.auth_methods.include?('password')
          # Verify captcha only when otp_code is not provided
          verify_captcha!(response: params['captcha_response'], endpoint: 'session_create') if params[:otp_code].nil?

          declared_params = declared(params, include_missing: false)
          user = get_user(declared_params[:email])

          # Verify captcha if user has disabled otp, but otp_code is provided
          if user.otp == false && declared_params[:otp_code].present?
            verify_captcha!(response: params['captcha_response'], endpoint: 'session_create')
          end

          unless user.authenticate(declared_params[:password])
            login_error!(reason: 'Invalid Email or Password', error_code: 401, user: user.id,
                         action: 'login', result: 'failed', error_text: 'invalid_params')
          end

          unless user.otp
            activity_record(user: user.id, action: 'login', result: 'succeed', topic: 'session')
            csrf_token = open_session(user)
            publish_session_create(user)

            present user, with: API::V2::Entities::UserWithFullInfo, csrf_token: csrf_token
            return status 200
          end

          error!({ errors: ['identity.session.missing_otp'] }, 401) if declared_params[:otp_code].blank?
          unless TOTPService.validate?(user.uid, declared_params[:otp_code])
            login_error!(reason: 'OTP code is invalid', error_code: 403,
                         user: user.id, action: 'login::2fa', result: 'failed', error_text: 'invalid_otp')
          end

          activity_record(user: user.id, action: 'login::2fa', result: 'succeed', topic: 'session')
          csrf_token = open_session(user)
          publish_session_create(user)

          present user, with: API::V2::Entities::UserWithFullInfo, csrf_token: csrf_token
          status(200)
        end

        desc 'Destroy current session',
          failure: [
            { code: 400, message: 'Required params are empty' },
            { code: 404, message: 'Record is not found' }
          ],
          success: { code: 200, message: 'Session was destroyed' }
        params do
          optional :auth_method,
                   type: String,
                   default: 'password',
                   values: { value: -> {  %w[password signature auth0] }, message: 'identity.session.invalid_auth_method' },
                   desc: 'Auth method'
        end
        delete do
          if params[:auth_method].in?(['password','auth0'])
            entity = User.find_by(uid: session[:uid])
            error!({ errors: ['identity.session.not_found'] }, 404) unless entity
            activity_record(user: entity.id, action: 'logout', result: 'succeed', topic: 'session')
          elsif params[:auth_method] == 'signature'
            entity = PublicAddress.find_by(uid: session[:uid])
            error!({ errors: ['identity.session.not_found'] }, 404) unless entity
          end

          Barong::RedisSession.delete(entity.uid, session.id)
          session.destroy

          status(200)
        end

        desc 'Auth0 authentication by id_token',
             success: { code: 200, message: 'User authenticated' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 404, message: 'Record is not found' }
             ]
        params do
          requires :id_token,
                   type: String,
                   allow_blank: false,
                   desc: 'ID Token'
        end
        post '/auth0' do
          error!({ errors: ['identity.session.endpoint_not_enabled'] }, 422) unless Barong::App.config.auth_methods.include?('auth0')

          begin
            # Decode ID token to get user info
            claims = Barong::Auth0::JWT.verify(params[:id_token]).first
            error!({ errors: ['identity.session.auth0.invalid_params'] }, 401) unless claims.key?('email')
            user = User.find_by(email: claims['email'])

            # If there is no user in platform and user email verified from id_token
            # system will create user
            if user.blank? && claims['email_verified']
              user = User.create!(email: claims['email'], state: 'active')
              user.labels.create!(scope: 'private', key: 'email', value: 'verified')
            elsif claims['email_verified'] == false
              error!({ errors: ['identity.session.auth0.invalid_params'] }, 401) unless user
            end

            activity_record(user: user.id, action: 'login', result: 'succeed', topic: 'session')
            csrf_token = open_session(user)
            publish_session_create(user)

            present user, with: API::V2::Entities::UserWithFullInfo, csrf_token: csrf_token
          rescue StandardError => e
            report_exception(e)
            error!({ errors: ['identity.session.auth0.invalid_params'] }, 422)
          end
        end

        desc 'Start session by signature',
          failure: [
            { code: 400, message: 'Required params are empty' },
            { code: 404, message: 'Record is not found' }
          ]
        params do
          requires :nickname, type: String, allow_blank: false, desc: -> { API::V2::Entities::PublicAddress.documentation[:address][:desc] }
          requires :nonce, type: String, allow_blank: false, desc: 'Auth Nonce in milliseconds'
          requires :signature, type: String, allow_blank: false, desc: 'Auth Signature'
          optional :captcha_response, type: String, desc: 'Response from captcha widget'
        end
        post '/signature' do
          error!({ errors: ['identity.session.endpoint_not_enabled'] }, 422) unless Barong::App.config.auth_methods.include?('signature')
          verify_captcha!(response: params['captcha_response'], endpoint: 'signature_session_create')

          # timestamp_window is a difference between server_time and nonce creation time
          nonce_timestamp_window = ((Time.now.to_f * 1000).to_i - params[:nonce].to_i).abs
          # (server_time - nonce) should not be more than nonce lifetime
          error!({ errors: ['identity.session.nonce_expired'] }, 422) if nonce_timestamp_window >= Barong::App.config.apikey_nonce_lifetime

          message = "#" + params[:nickname] + "#" + params[:nonce]
          hashed_message = Barong::Signature.blake2_as_hex(message)

          unless Barong::Signature.signature_verify?(hashed_message, params[:signature], params[:nickname])
            error!({ errors: ['identity.session.signature.verification_failed'] }, 422)
          end

          public_address = PublicAddress.find_by(address: params[:nickname])
          unless public_address
            public_address = PublicAddress.create(address: params[:nickname], role: 'member')
          end

          csrf_token = open_session(public_address)

          present public_address, with: API::V2::Entities::PublicAddress, csrf_token: csrf_token
        end


        desc 'Signin a user from Auth0 login custom flow',
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 404, message: 'Record is not found' }
             ]
        params do
          requires :email
          requires :password
          requires :code
        end
        post '/auth0/signin' do
          error!({ errors: ['identity.session.endpoint_not_enabled'] }, 422) unless Barong::App.config.auth_methods.include?('password')
          
          declared_params = declared(params, include_missing: false)
          error!({ errors: ['identity.session.endpoint_not_allowed'] }, 405) unless Barong::App.config.auth0_client_id == declared_params[:code]

          user = get_user(declared_params[:email])

          unless user.authenticate(declared_params[:password])
            login_error!(reason: 'Invalid Email or Password', error_code: 401, user: user.id,
                         action: 'login', result: 'failed', error_text: 'invalid_params')
          end

          present user, with: API::V2::Entities::UserWithFullInfo
          return status 200
        end
      end
    end
  end
end
