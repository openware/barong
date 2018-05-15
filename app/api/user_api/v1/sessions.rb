# frozen_string_literal: true

module UserApi
  module V1
    class Sessions < Grape::API
      desc 'Session related routes'
      resource :sessions do
        desc 'Start a new session'
        params do
          requires :email
          requires :password
          requires :application_id
          optional :expires_in, allow_blank: false
        end

        post do
          declared_params = declared(params, include_missing: false)
          acc = Account.kept.find_by(email: declared_params[:email])

          return error!('Invalid Email or password.', 401) unless acc

          app = Doorkeeper::Application.find_by(uid: declared_params[:application_id])
          return error!('Wrong application id', 401) unless app
          if acc.valid_password? declared_params[:password]
            return error!('You have to confirm your email address before continuing.', 401) unless acc.active_for_authentication?
            Barong::Security::AccessToken.create declared_params[:expires_in], acc.id, app
          else
            error!('Invalid Email or password.', 401)
          end
        end

        desc 'Validates client jwt and generates peatio session jwt'
        params do
          requires :kid, type: String, allow_blank: false, desc: 'API Key uid'
          requires :jwt_token, type: String, allow_blank: false
        end
        post 'generate_jwt' do
          status 200
          declared_params = declared(params).symbolize_keys
          generator = SessionJWTGenerator.new declared_params
          error!('Payload is invalid', 401) unless generator.verify_payload

          { token: generator.generate_session_jwt }
        rescue JWT::DecodeError => e
          error! "Failed to decode and verify JWT: #{e.inspect}", 401
        end
      end
    end
  end
end
