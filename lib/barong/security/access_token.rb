# frozen_string_literal: true

module Barong
  module Security
    # Helpers for JWT
    module AccessToken
      ALGORITHM = 'HS256'

      class <<self
        def generate_jwt(account_uid:, expires_in:)
          secret_key = Rails.application.secrets.secret_key_base
          expires_in ||= 4.hours

          payload = {
            account_uid: account_uid,
            iat: Time.current.to_i,
            jti: SecureRandom.hex(12).upcase,
            exp: expires_in.to_i.seconds.from_now.to_i,
            sub: 'session',
            iss: 'barong'
          }

          JWT.encode(payload, secret_key, ALGORITHM)
        end

        def create(expires_in, acc_id, application)
          # Doorkeeper method, which creates the JWT for the current user with scope 'peatio' and expiration time specified earlier
          # Don't be confused by 'find' in method's name,
          # according to source code it returns old token if access_tokens are reusable(can be specified in config)
          return unless acc_id
          Doorkeeper::AccessToken.find_or_create_for(
            application,
            acc_id,
            Doorkeeper.configuration.scopes.to_s,
            expires_in || Doorkeeper.configuration.access_token_expires_in,
            false
          ).token
        end
      end
    end
  end
end
