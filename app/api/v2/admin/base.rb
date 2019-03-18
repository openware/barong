# frozen_string_literal: true

require_dependency 'barong/middleware/jwt_authenticator'

module API::V2
  module Admin
    class Base < Grape::API
      use Barong::Middleware::JWTAuthenticator, \
        pubkey: Rails.configuration.x.keystore.public_key

      cascade false

      format         :json
      content_type   :json, 'application/json'
      default_format :json

      helpers API::V2::Resource::Utils

      do_not_route_options!

      before do
        error!({ errors: ['admin.access.denied'] }, 401) unless current_user.role.admin?
      end

      mount Admin::Users
      mount Admin::Permissions
    end
  end
end
