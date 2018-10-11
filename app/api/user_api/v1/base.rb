# frozen_string_literal: true

module UserApi
  module V1
    class Base < Grape::API
      version 'v1', using: :path

      cascade false

      format         :json
      content_type   :json, 'application/json'
      default_format :json

      logger Rails.logger.dup
      logger.formatter = GrapeLogging::Formatters::Rails.new
      use GrapeLogging::Middleware::RequestLogger,
          logger:    logger,
          log_level: :info,
          include:   [GrapeLogging::Loggers::Response.new,
                      GrapeLogging::Loggers::FilterParameters.new,
                      GrapeLogging::Loggers::ClientEnv.new,
                      GrapeLogging::Loggers::RequestHeaders.new]

      helpers V1::Helpers

      do_not_route_options!

      rescue_from(ActiveRecord::RecordNotFound) { |_e| error!('Record is not found', 404) }
      # Known Vault Error from Vault::TOTP.with_human_error
      rescue_from(Vault::TOTP::Error) do |error|
        error!(error.message, 422)
      end
      # Unknown Vault error
      rescue_from(Vault::VaultError) do |error|
        Rails.logger.error "#{error.class}: #{error.message}"
        error!('Something wrong with 2FA', 422)
      end

      rescue_from(Twilio::REST::RestError) do |error|
        Rails.logger.error "Twilio Client Error: #{error.message}"
        error!('Something wrong with Twilio Client', 500)
      end

      rescue_from(Grape::Exceptions::ValidationErrors) do |error|
        error!(error.message, 400)
      end

      rescue_from(:all) do |error|
        Rails.logger.error "#{error.class}: #{error.message}"
        error!('Something went wrong', 500)
      end

      use UserApi::V1::CORS::Middleware

      mount UserApi::V1::Accounts
      mount UserApi::V1::Profiles
      mount UserApi::V1::Security
      mount UserApi::V1::Documents
      mount UserApi::V1::Phones
      mount UserApi::V1::Sessions
      mount UserApi::V1::Labels
      mount UserApi::V1::APIKeys

      add_swagger_documentation base_path: '/api',
                                info: {
                                  title: 'Barong',
                                  description: 'API for barong OAuth server '
                                },
                                security_definitions: {
                                  "BearerToken": {
                                    description: 'Bearer Token authentication',
                                    type: 'apiKey',
                                    name: 'Authorization',
                                    in: 'header'
                                  }
                                },
                                models: [
                                  Entities::Label,
                                  Entities::APIKey
                                ],
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
