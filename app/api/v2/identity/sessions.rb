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
          optional :remember_me,
                   type: Boolean
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

          unless user.authenticate(declared_params[:password])
            login_error!(reason: 'Invalid Email or Password', error_code: 401, user: user.id,
                         action: 'login', result: 'failed', error_text: 'invalid_params')
          end

          unless user.otp
            activity_record(user: user.id, action: 'login', result: 'succeed', topic: 'session')
            session[:uid] = user.uid

            if Barong::App.config.allow_remember && params[:remember_me]
              exp = (Time.now + 30.days).to_i
              agent = request.env["HTTP_USER_AGENT"] # check for not nil
              jwt = codec.encode(uid: user.uid, ip: request.ip, agent: agent, exp: exp)
              cookies[:device_jwt] = { value: jwt, expires: Time.now + 30.days, domain: Barong::App.config.barong_domain }
            end

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

        desc 'Renew current session by jwt',
          failure: [
            { code: 400, message: 'Required params are empty' },
            { code: 404, message: 'Record is not found' }
        ]
        post '/renew' do
          error!({ errors: ['identity.session.invalid_login_params'] }, 401) unless cookies[:device_jwt]
          error!({ errors: ['identity.session.invalid_login_params'] }, 401) unless Barong::App.config.allow_remember

          ip, uid, agent = codec.decode_and_verify(
                                  cookies[:device_jwt],
                                  pub_key: Barong::App.config.keystore.public_key,
                                  sub: 'session',
                                ).slice(:ip, :uid, :agent).values

          user = User.find_by(uid: uid)
          error!({ errors: ['identity.session.invalid_login_params'] }, 401) unless user

          if user.state == 'banned'
            login_error!(reason: 'Your account is banned', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'banned')
          end

          if user.state == 'discarded'
            login_error!(reason: 'Your account is discarded', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'discarded')
          end

          if user.otp
            login_error!(reason: 'Login with remembered device with enabled 2FA', error_code: 422,
              user: user.id, action: 'login::device', result: 'failed', error_text: 'enabled_2fa')
          end

          unless request.ip == ip
            login_error!(reason: 'Invalid device JWT IP', error_code: 422,
              user: user.id, action: 'login::device', result: 'failed', error_text: 'invalid_jwt')
          end

          unless request.env["HTTP_USER_AGENT"] == agent
            login_error!(reason: 'Invalid device JWT agent', error_code: 422,
              user: user.id, action: 'login::device', result: 'failed', error_text: 'invalid_jwt')
          end

          activity_record(user: user.id, action: 'login', result: 'succeed', topic: 'session')
          session[:uid] = user.uid

          present user, with: API::V2::Entities::User
          return status 200
        end

        desc 'Destroy current session',
          failure: [
            { code: 400, message: 'Required params are empty' },
            { code: 404, message: 'Record is not found' }
        ]
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
