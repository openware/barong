# frozen_string_literal: true

module API
  module V1
    class Base < Grape::API
      format :json

      before do
        doorkeeper_authorize!

        def current_account
          @current_account = Account.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
        end
      end

      mount API::V1::Accounts
      mount API::V1::Profiles
      mount API::V1::Admin::Base

      add_swagger_documentation base_path: '/api',
                                info: {
                                  title: 'Barong',
                                  description: 'API for barong OAuth server '
                                },
                                api_version: 'v1',
                                target_class: API::V1::Accounts,
                                hide_format: true,
                                hide_documentation_path: true,
                                mount_path: '/swagger_doc'

      route :any, '*path' do
        raise StandardError, 'Unable to find endpoint'
      end
    end
  end
end
