# frozen_string_literal: true

require 'barong/security/access_token'

module UserApi
  module V1
    class SessionJWTGenerator
      ALGORITHM = 'RS256'

      def initialize(params = {})
        @kid = params[:kid]
        @signature = params[:signature]
        @nonce = params[:nonce] || nil
        @api_key = APIKey.active.find_by!(kid: @kid)
      end

      def verify_hmac_payload
        data = @nonce.to_s + @kid
        secret = Vault::APISecretsStorage.get_secret(@kid)
        algorithm = 'SHA' + @api_key.algorithm[2..4]
        true_signature = OpenSSL::HMAC.hexdigest(algorithm, secret, data)
        true_signature == @signature
      end

      def verify_rsa_payload
        payload, = decode_payload
        payload.present?
      end

      # configure expire time by ENV
      def generate_session_jwt
        account = @api_key.account
        payload = {
          iat: Time.current.to_i,
          exp: Time.current.to_i + 1.days.to_i,
          sub: 'session',
          iss: 'barong',
          aud: @api_key.scopes,
          jti: SecureRandom.hex(12).upcase,
          uid:   account.uid,
          email: account.email,
          role:  account.role,
          level: account.level,
          state: account.state,
          api_kid: @api_key.kid
        }

        JWT.encode(payload, Barong::Security.private_key, ALGORITHM)
      end

    private

      def decode_payload
        signature = OpenSSL::PKey.read(Base64.urlsafe_decode64(@api_key.kid))
        return {} if signature.private?

        JWT.decode(@kid,
                   signature,
                   true,
                   APIKey::JWT_OPTIONS)
      end
    end
  end
end
