# frozen_string_literal: true

require_dependency 'barong/middleware/jwt_authenticator'

module API::V2
  module Commercial
    class Base < Grape::API
      PREFIX = '/commercial'

      use Barong::Middleware::JWTAuthenticator, \
          pubkey: Rails.configuration.x.keystore.public_key

      cascade false

      format         :json
      content_type   :json, 'application/json'
      default_format :json

      helpers API::V2::Resource::Utils

      do_not_route_options!

      mount Commercial::Accounts
      mount Commercial::Organizations
    end
  end
end
