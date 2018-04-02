# frozen_string_literal: true

module API
  module V1
    class Base < Grape::API
      version 'v1', using: :path

      format :json
      content_type   :json, 'application/json'
      default_format :json

      mount V1::Accounts
      mount V1::Documents
      mount V1::Security
      mount V1::Session
      mount V1::Profiles

      add_swagger_documentation \
        mount_path:  '/swagger',
        base_path:   '/api/v1',
        api_version: 'v1',
        add_version: false,
        doc_version: '1.5.0',
        info: {
          title:        'Barong REST API',
          description:  'Barong OAuth and KYC service REST API.',
          contact_name: 'Helios Technologies',
          license:      'Apache License 2.0',
          license_url:  'https://github.com/rubykube/barong/blob/master/LICENSE.md'
        }
    end
  end
end
