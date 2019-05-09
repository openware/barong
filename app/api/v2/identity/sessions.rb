# frozen_string_literal: true

require_dependency 'barong/jwt'

module API::V2
  module Identity
    class Sessions < Grape::API
      use ActionDispatch::Session::CookieStore

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
          declared_params = declared(params, include_missing: false)
          user = User.find_by(email: declared_params[:email])

          if declared_params[:captcha_response]
            verify_captcha!(user: user, response: params['captcha_response'])
          end

          error!({ errors: ['identity.session.invalid_login_params'] }, 401) unless user

          if user.state == 'banned'
            login_error!(reason: 'Your account is banned', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'banned')
          end

          if user.state == 'discarded'
            login_error!(reason: 'Your account is discarded', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'discarded')
          end

          unless user.active?
            login_error!(reason: 'Your account is not active', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'not_active')
          end

          unless user.authenticate(declared_params[:password])
            login_error!(reason: 'Invalid Email or Password', error_code: 401, user: user.id,
                         action: 'login', result: 'failed', error_text: 'invalid_params')
          end

          unless user.otp
            # place for refresh lock logic
            activity_record(user: user.id, action: 'login', result: 'succeed', topic: 'session')
            session[:uid] = user.uid

            present user, with: API::V2::Entities::User
            return status 200
          end

          if declared_params[:otp_code].blank?
            login_error!(reason: 'The account has enabled 2FA but OTP code is missing', error_code: 403,
                         user: user.id, action: 'login::2fa', result: 'failed', error_text: 'missing_otp')
          end

          unless TOTPService.validate?(user.uid, declared_params[:otp_code])
            login_error!(reason: 'OTP code is invalid', error_code: 403,
                         user: user.id, action: 'login::2fa', result: 'failed', error_text: 'invalid_otp')
          end

          activity_record(user: user.id, action: 'login::2fa', result: 'succeed', topic: 'session')
          session[:uid] = user.uid

          present user, with: API::V2::Entities::User
          status(200)
        end

        desc 'Destroy current session',
          failure: [
            { code: 400, message: 'Required params are empty' },
            { code: 404, message: 'Record is not found' }
        ]
        params do
        end
        delete do
          user = User.find_by!(uid: session[:uid])
          error!({ errors: ['identity.session.invalid'] }, 401) unless user

          activity_record(user: user.id, action: 'logout', result: 'succeed', topic: 'session')

          session.destroy
          status(200)
        end
      end
    end
  end
end
