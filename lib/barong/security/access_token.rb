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
      class <<self
        def create(expires_in, acc_id, application)
          # Doorkeeper method, which creates the JWT for the current user with scope 'peatio' and expiration time specified earlier
          # Don't be confused by 'find' in method's name,
          # according to source code it returns old token if access_tokens are reusable(can be specified in config)
          return unless acc_id

          if expires_in && (expires_in.to_i < 30.minutes || expires_in.to_i >= 24.hours.to_i)
            raise "expires_in must be from #{30.minutes} to #{24.hours.to_i} seconds"
          end

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
