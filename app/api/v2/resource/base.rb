# frozen_string_literal: true

require_dependency 'barong/middleware/jwt_authenticator'

module API::V2
  module Resource
    class Base < Grape::API
      use Barong::Middleware::JWTAuthenticator

      version 'v2', using: :path

      cascade false

      format         :json
      content_type   :json, 'application/json'
      default_format :json

      do_not_route_options!

      rescue_from(ActiveRecord::RecordNotFound) do |_e|
        error!('Record is not found', 404)
      end

      rescue_from(Grape::Exceptions::ValidationErrors) do |error|
        error!(error.message, 400)
      end

      rescue_from(:all) do |error|
        Rails.logger.error "#{error.class}: #{error.message}"
        error!('Something went wrong', 500)
      end

      mount Resource::Users

      route :any, '*path' do
        error! 'Route is not found', 404
      end
    end
  end
end
