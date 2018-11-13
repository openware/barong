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
          # optional :otp_code, type: String,
          #                     desc: 'Code from Google Authenticator'
        end
        post do
          declared_params = declared(params, include_missing: false)
          user = User.find_by(email: declared_params[:email])

          verify_captcha!(user: user, 
                          response: params['recaptcha_response']) if declared_params[:recaptcha_response]

          error!('Invalid Email or Password', 401) unless user
          error!('Your account is not active', 401) unless user.active?
          error!('Invalid Email or Password', 401) unless user.authenticate(declared_params[:password])
          unless user.otp
            # place for refresh lock logic
            session[:uid] = user.uid
            return status 200 
          end

          if declared_params[:otp_code].blank?
            # user.add_failed_attempt
            error!('The account has enabled 2FA but OTP code is missing', 403)
          end

          unless TOTPService.validate?(user.uid, declared_params[:otp_code])
            # user.add_failed_attempt
            error!('OTP code is invalid', 403)
          end
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

          session.destroy
          status(200)
        end

        namespace :authorize do
          # AuthZ story
          desc 'Traffic Authorizer EndPoint',
            failure: [
              { code: 400, message: 'Request is invalid' },
              { code: 404, message: 'Destination endpoint is not found' }
          ]
          params do
            requires :path
          end
          head '*path' do
            # TODO: check for Authorization header
            # 'X-Auth-Apikey': apiKey,
            # 'X-Auth-Nounce': payload,
            # 'X-Auth-Signature': signature

            error!('Invalid Session', 401) unless session[:uid]
            user = User.find_by!(uid: session[:uid])
            header 'Authorization', codec.encode(user.as_payload)

            status(200)
          end
        end
      end
    end
  end
end
