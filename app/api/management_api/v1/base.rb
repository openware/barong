# frozen_string_literal: true

module ManagementAPI
  module V1
    class Base < Grape::API
      version 'v1', using: :path

      cascade false

      format         :json
      content_type   :json, 'application/json'
      default_format :json

      do_not_route_options!

      rescue_from(ManagementAPI::V1::Exceptions::Base) { |e| error!(e.message, e.status, e.headers) }
      rescue_from(Grape::Exceptions::ValidationErrors) { |e| error!(e.message, 422) }
      rescue_from(ActiveRecord::RecordNotFound) { error!('Record is not found', 404) }

      use ManagementAPI::V1::JWTAuthenticationMiddleware

      mount ManagementAPI::V1::OTP
      mount ManagementAPI::V1::Labels
      mount ManagementAPI::V1::Accounts
      mount ManagementAPI::V1::Tools

      add_swagger_documentation base_path: '/management_api',
                                info: {
                                  title: 'Management API v1',
                                  description: 'Management API is server-to-server API with high privileges'
                                },
                                api_version: 'v1',
                                doc_version: Barong::VERSION,
                                hide_format: true,
                                hide_documentation_path: true,
                                mount_path: '/swagger_doc'

      route :any, '*path' do
        error! 'Unable to find endpoint', 404
      end
    end
  end
end
