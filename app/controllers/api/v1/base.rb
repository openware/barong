# frozen_string_literal: true

module API
  module V1
    class Base < Grape::API
      version 'v1', using: :path

      cascade false

      format         :json
      content_type   :json, 'application/json'
      default_format :json

      helpers V1::Helpers

      do_not_route_options!

      rescue_from(ActiveRecord::RecordNotFound) { error!(:not_found, 404) }
      rescue_from(Vault::VaultError) do |error|
        error_message = error.message
        Rails.logger.error "#{error.class}: #{error_message}"
        error!(error_message, 500)
      end

      mount API::V1::Accounts
      mount API::V1::Profiles
      mount API::V1::Security
      mount API::V1::Documents
      mount API::V1::Phones
      mount API::V1::Sessions
      mount API::V1::Labels

      add_swagger_documentation base_path: '/api',
                                info: {
                                  title: 'Barong',
                                  description: 'API for barong OAuth server '
                                },
                                api_version: 'v1',
                                hide_format: true,
                                hide_documentation_path: true,
                                mount_path: '/swagger_doc'

      route :any, '*path' do
        raise StandardError, 'Unable to find endpoint'
      end
    end
  end
end
