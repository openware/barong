# frozen_string_literal: true

module Barong
  # Security module
  module Security
    class << self
      extend Memoist

      def private_key
        key_path = ENV['JWT_PRIVATE_KEY_PATH']
        raw_private_key = if key_path.present?
                            File.read(key_path)
                          else
                            Base64.urlsafe_decode64(Rails.application.secrets.jwt_shared_secret_key)
                          end
        OpenSSL::PKey.read raw_private_key
      end
      memoize :private_key
    end

    # Helpers for JWT
    module AccessToken
      module Blacklist
        class <<self
          def push(payload)
            redis.set(payload['jti'], 0)
            redis.expireat(payload['jti'], payload['exp'])
          end

          def include?(jti)
            redis.exists(jti)
          end

        private

          def redis
            Rails.application.config.blacklist_redis
          end
        end
      end

      class <<self
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

        def expire(token)
          Blacklist.push(decode(token))
        end

        def blacklisted?(token)
          Blacklist.include?(decode(token)['jti'])
        end

      private

        def decode(token)
          JWT.decode(token,
                     Barong::Security.private_key.public_key,
                     true,
                     algorithm: 'RS256').first
        end
      end
    end
  end
end
