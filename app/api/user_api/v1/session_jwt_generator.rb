# frozen_string_literal: true

module UserApi
  module V1
    class SessionJwtGenerator
      ALGORITHM = 'RS256'

      def initialize(jwt_token:, key_uid:)
        @key_uid = key_uid
        @jwt_token = jwt_token
        @api_key = APIKey.active.find_by!(uid: key_uid)
      end

      def verify_payload
        payload, = decode_payload
        payload['key_uid'] == @key_uid
      end

      def generate_session_jwt
        account = @api_key.account
        payload = {
          iat: Time.current.to_i,
          exp: @api_key.expires_in.seconds.from_now.to_i,
          sub: 'session',
          iss: 'barong',
          aud: @api_key.scopes,
          jti: SecureRandom.hex(12).upcase,
          uid:   account.uid,
          email: account.email,
          role:  account.role,
          level: account.level,
          state: account.state,
          api_key_uid: @api_key.uid
        }

        JWT.encode(payload, secret_key, ALGORITHM)
      end

    private

      def secret_key
        key_path = ENV['JWT_PRIVATE_KEY_PATH']
        private_key = if key_path.present?
                        File.read(key_path)
                      else
                        Base64.urlsafe_decode64(Rails.application.secrets.jwt_shared_secret_key)
                      end

        OpenSSL::PKey.read private_key
      end

      def decode_payload
        public_key = OpenSSL::PKey.read(Base64.urlsafe_decode64(@api_key.public_key))
        return {} if public_key.private?

        JWT.decode(@jwt_token,
                   public_key,
                   true,
                   APIKey::JWT_OPTIONS)
      end
    end
  end
end
