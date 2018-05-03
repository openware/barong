# frozen_string_literal: true

require_dependency 'user_api/errors'
require_dependency 'barong/security/access_token'

module UserApi
  module V1
    class Base < Grape::API
      version 'v1', using: :path

      cascade false

      format         :json
      content_type   :json, 'application/json'
      default_format :json

      helpers V1::Helpers
      use V1::Auth::Middleware

      do_not_route_options!

      rescue_from(ActiveRecord::RecordNotFound) { error!('Record is not found', 404) }
      rescue_from(Vault::VaultError) do |error|
        error_message = error.message
        Rails.logger.error "#{error.class}: #{error_message}"
        error!(error_message, 500)
      end

      rescue_from(Twilio::REST::RestError) do |error|
        Rails.logger.error "Twilio Client Error: #{error.message}"
        error!('Something wrong with Twilio Client', 500)
      end

      rescue_from(Grape::Exceptions::ValidationErrors) do |error|
        error!(error.message, 400)
      end

      rescue_from(UserApi::AuthorizationError) do |error|
        error!(error.message, 401)
      end

      rescue_from(:all) do |error|
        Rails.logger.error "#{error.class}: #{error.message}"
        error!('Something went wrong', 500)
      end

      mount UserApi::V1::Accounts
      mount UserApi::V1::Profiles
      mount UserApi::V1::Security
      mount UserApi::V1::Documents
      mount UserApi::V1::Phones
      mount UserApi::V1::Sessions
      mount UserApi::V1::Labels

      add_swagger_documentation base_path: '/api',
                                info: {
                                  title: 'Barong',
                                  description: 'API for barong OAuth server '
                                },
                                api_version: 'v1',
                                doc_version: Barong::VERSION,
                                hide_format: true,
                                hide_documentation_path: true,
                                mount_path: '/swagger_doc'

      route :any, '*path' do
        raise StandardError, 'Unable to find endpoint'
      end
    end
  end
end
