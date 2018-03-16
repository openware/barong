# frozen_string_literal: true

module Barong
  module Security
    # Helpers for JWT
    module AccessToken
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
      end
    end
  end
end
