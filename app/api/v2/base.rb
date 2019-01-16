# frozen_string_literal: true

require_dependency 'v2/validations'

module API::V2
  # Base api configuration for V2 module
  class Base < Grape::API
    cascade false

    format         :json
    content_type   :json, 'application/json'
    default_format :json

    mount Admin::Base      => '/admin'
    mount Identity::Base   => '/identity'
    mount Resource::Base   => '/resource'

    add_swagger_documentation base_path: '/api/v2/*/',
    info: {
      title: 'Barong',
      description: 'RESTful API for barong OAuth server'
    },
    security_definitions: {
      "BearerToken": {
        description: 'Bearer Token authentication',
        type: 'jwt',
        name: 'Authorization',
        in: 'header'
      }
    },
    models: [
      Entities::Label,
      Entities::APIKey,
      Entities::Profile,
      Entities::User,
      Entities::UserWithProfile,
      Entities::UserWithFullInfo,
      Entities::Phone
    ],
    api_version: 'v2',
    doc_version: '2.0.30-alpha', # Used to be BARONG::VERSION
    hide_format: true,
    hide_documentation_path: true,
    mount_path: '/restful_api.json'

    mount Management::Base => '/management'
    route :any, '*path' do
      error! 'Route is not found', 404
    end
  end
end
