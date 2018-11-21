# frozen_string_literal: true

require_dependency 'barong/jwt'

module API::V2
  module Identity
    class Sessions < Grape::API

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
          optional :recaptcha_response, type: String,
                                        desc: 'Response from Recaptcha widget'
          optional :otp_code, type: String,
                              desc: 'Code from Google Authenticator'
        end
        post do
          declared_params = declared(params, include_missing: false)
          user = User.find_by(email: declared_params[:email])

          verify_captcha!(user: user,
                          response: params['recaptcha_response']) if declared_params[:recaptcha_response]

          error!('Invalid Email or Password', 401) unless user
          login_error!(reason: 'Your account is not active', error_code: 401,
                       user: user.id, action: 'login', result: 'failed') unless user.active?
          login_error!(reason: 'Invalid Email or Password', error_code: 401, user: user.id,
                       action: 'login', result: 'failed') unless user.authenticate(declared_params[:password])

          unless user.otp
            # place for refresh lock logic
            session_activity(user: user.id, action: 'login', result: 'succeed')
            session[:uid] = user.uid
            return status 200 
          end

          if declared_params[:otp_code].blank?
            login_error!(reason: 'The account has enabled 2FA but OTP code is missing', error_code: 403,
                         user: user.id, action: 'login::2fa', result: 'failed')
          end

          unless TOTPService.validate?(user.uid, declared_params[:otp_code])
            login_error!(reason: 'OTP code is invalid', error_code: 403,
                         user: user.id, action: 'login::2fa', result: 'failed')
          end

          session_activity(user: user.id, action: 'login::2fa', result: 'succeed')
          session[:uid] = user.uid
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
          error!('Invalid Session', 401) unless user

          session_activity(user: user.id, action: 'logout', result: 'succeed')

          session.destroy
          status(200)
        end

        namespace :authorize do
          desc 'Traffic Authorizer EndPoint',
            failure: [
              { code: 400, message: 'Request is invalid' },
              { code: 404, message: 'Destination endpoint is not found' }
          ]
          params do
            requires :path
          end
          route :any, '/api/v2/barong/identity/(*:path)' do
            status(200)
          end

          desc 'Traffic Authorizer EndPoint',
            failure: [
              { code: 400, message: 'Request is invalid' },
              { code: 404, message: 'Destination endpoint is not found' }
          ]
          params do
            requires :path
          end
          route ['GET','POST','HEAD','PUT'], '/(*:path)' do

            if apikey_headers?
              apiKey = APIKeysVerifier.new(apikey_params)
              error!('Invalid or unsupported signature', 401) unless apiKey.verify_hmac_payload?
              # generate JWT for API KEY
              status(200)
            else
              error!('Invalid Session', 401) unless session[:uid]
              user = User.find_by!(uid: session[:uid])
              header 'Authorization', 'Bearer ' + codec.encode(user.as_payload)
              return status(200)
            end
          end
        end
      end
    end
  end
end
