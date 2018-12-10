# frozen_string_literal: true

require_dependency 'barong/middleware/jwt_authenticator'

module API::V2
  module Resource
    class Base < Grape::API
      use Barong::Middleware::JWTAuthenticator, \
        pubkey: Rails.configuration.x.keystore.public_key

      helpers API::V2::Resource::Utils

      do_not_route_options!

      rescue_from(ActiveRecord::RecordNotFound) do |_e|
        error!('Record is not found', 404)
      end

      rescue_from(Grape::Exceptions::ValidationErrors) do |error|
        error!(error.message, 400)
      end

      rescue_from Peatio::Auth::Error do |e|
        if Rails.env.production?
          error!('Permission Denied', 401)
        else
          Rails.logger.error "#{e.class}: #{e.message}"
          error!({ error: { code: e.code, message: e.message } }, 401)
        end
      end

      # Known Vault Error from TOTPService.with_human_error
      rescue_from(TOTPService::Error) do |error|
        error!(error.message, 422)
      end

      rescue_from(:all) do |error|
        Rails.logger.error "#{error.class}: #{error.message}"
        error!('Something went wrong', 500)
      end

      mount Resource::Users
      mount Resource::Profiles
      mount Resource::Documents
      mount Resource::Phones
      mount Resource::Otp
      mount Resource::APIKeys
    end
  end
end
