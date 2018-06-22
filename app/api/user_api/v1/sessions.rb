# frozen_string_literal: true

module UserApi
  module V1
    class Sessions < Grape::API
      desc 'Session related routes'
      resource :sessions do
        desc 'Start a new session',
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 404, message: 'Record is not found' }
             ]
        params do
          requires :email
          requires :password
          requires :application_id
          optional :remember_me, type: Boolean
          optional :expires_in, allow_blank: false
          optional :otp_code, type: String,
                              desc: 'Code from Google Authenticator'
        end

        post do
          ::Services::AuthService.sign_in(params: declared(params),
                                          device_params: env['device_params'],
                                          device_uuid: env['device_uuid'])
        end

        desc 'Validates client jwt and generates peatio session jwt',
             success: { code: 200, message: 'Session is generated' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'JWT is invalid' }
             ]
        params do
          requires :kid, type: String, allow_blank: false, desc: 'API Key uid'
          requires :jwt_token, type: String, allow_blank: false
        end
        post 'generate_jwt' do
          status 200
          api_key = APIKey.active.find_by!(uid: params[:kid])
          generator = ::Services::SessionJWTGenerator.new(jwt_token: params[:jwt_token],
                                                          api_key: api_key)

          error!('Payload is invalid', 401) unless generator.verify_payload
          { token: generator.generate_session_jwt }
        rescue JWT::DecodeError => e
          error! "Failed to decode and verify JWT: #{e.inspect}", 401
        end
      end
    end
  end
end
