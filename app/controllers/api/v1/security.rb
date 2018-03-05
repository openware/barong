require 'jwt'

module API
  module V1
    class Security < Grape::API
      desc 'otp sign validation'
      resource :security do
        desc 'Validates otp for user, signs the payload with JWT and returns it'
        post '/otpsign' do
          if Account.find_by(uid: params[:uid]).verify_otp(params[:otp])
            secret = Base64.urlsafe_decode64(Rails.application.secrets.jwt_shared_secret_key)
            rsa = OpenSSL::PKey::RSA.new(secret)
            payload = params[:payload]
            p params
            jwt = JWT.encode payload, rsa, 'RS256'
            return { jwt: jwt, type: 'otpsign' }.to_json
          else
            error! 'Access Denied', 401
          end
        end
      end
    end
  end
end
