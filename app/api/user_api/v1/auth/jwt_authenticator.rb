# frozen_string_literal: true

module UserApi
  module V1
    module Auth
      class JWTAuthenticator
        def initialize(token)
          @token_type, @token_value = token.to_s.split(' ')
        end

        #
        # Decodes and verifies JWT.
        # Returns authentic account uid or raises an exception.
        def authenticate!(options = {})
          unless @token_type == 'Bearer'
            raise AuthorizationError, 'Token type is not provided or invalid.'
          end

          payload, = decode_and_verify_token(@token_value)
          payload.fetch('account_uid')
        end

      private

        def decode_and_verify_token(token)
          JWT.decode(token,
                     Rails.application.secrets.secret_key_base,
                     true,
                     token_verification_options)
        rescue JWT::DecodeError => e
          raise AuthorizationError, "Failed to decode and verify JWT: #{e.inspect}."
        end

        def token_verification_options
          {
            verify_expiration: true,
            verify_iat: true,
            verify_jti: true,
            sub: 'session',
            verify_sub: true,
            algorithms: [Barong::Security::AccessToken::ALGORITHM],
            iss: 'barong',
            verify_iss: true
          }
        end
      end
    end
  end
end
