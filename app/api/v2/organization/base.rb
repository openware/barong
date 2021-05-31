# frozen_string_literal: true

require_dependency 'barong/middleware/jwt_authenticator'

module API::V2
  module Organization
    class Base < Grape::API
      PREFIX = '/organization'

      use Barong::Middleware::JWTAuthenticator, \
          pubkey: Rails.configuration.x.keystore.public_key

      cascade false

      format         :json
      content_type   :json, 'application/json'
      default_format :json

      helpers API::V2::Resource::Utils

      do_not_route_options!

      mount API::V2::Organization::Accounts
      mount API::V2::Organization::Organizations
      mount API::V2::Organization::Account
      mount API::V2::Organization::Users
    end
  end
end
