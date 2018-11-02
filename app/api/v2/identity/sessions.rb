# frozen_string_literal: true

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
          # optional :otp_code, type: String,
          #                     desc: 'Code from Google Authenticator'
        end
        post do
          declared_params = declared(params, include_missing: false)
          user = User.find_by(email: declared_params[:email])
          error!('Invalid Email or Password', 401) unless user
          error!('Your account is not active', 401) unless user.active?
          error!('Invalid Email or Password', 401) unless user.authenticate(declared_params[:password])
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
          session.destroy

          status(200)
        end

        # AuthZ story
        desc 'Traffic Authorizer EndPoint',
          failure: [
            { code: 400, message: 'Required params are empty' },
            { code: 404, message: 'Record is not found' }
        ]
        params do
          requires :path
        end
        head 'authorize/:path' do
          # TODO: check for Authorization header
          # 'X-Auth-Apikey': apiKey,
          # 'X-Auth-Nounce': payload,
          # 'X-Auth-Signature': signature
          if session[:uid]
            user = User.find_by!(uid: session[:uid])
            header 'Authorization', codec.encode(user.as_payload)
            status(200)
          else
            error!('Invalid Session', 401)
          end
        end
      end
    end

  end
end
