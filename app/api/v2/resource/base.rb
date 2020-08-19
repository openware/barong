# frozen_string_literal: true

require_dependency 'barong/middleware/jwt_authenticator'

module API::V2
  module Resource
    class Base < Grape::API
      use Barong::Middleware::JWTAuthenticator, \
        pubkey: Rails.configuration.x.keystore.public_key

      helpers API::V2::Resource::Utils

      do_not_route_options!

      mount Resource::Addresses
      mount Resource::Users
      mount Resource::Labels
      mount Resource::Profiles
      mount Resource::Documents
      mount Resource::Phones
      mount Resource::Otp
      mount Resource::APIKeys
      mount Resource::DataStorage
      mount Resource::Providers
    end
  end
end
