module API::V2
  module Management
    class Base < Grape::API
      do_not_route_options!

      rescue_from(API::V2::Management::Exceptions::Base) { |e| error!(e.message, e.status, e.headers) }
      rescue_from(Grape::Exceptions::ValidationErrors) { |e| error!(e.message, 422) }
      rescue_from(ActiveRecord::RecordNotFound) { error!('Record is not found', 404) }

      # Known Vault Error from TOTPService.with_human_error
      rescue_from(TOTPService::Error) do |error|
        error!(error.message, 422)
      end

      use API::V2::Management::JWTAuthenticationMiddleware
      mount API::V2::Management::Labels
      mount API::V2::Management::Users
      mount API::V2::Management::Profiles
      mount API::V2::Management::Phones
      mount API::V2::Management::Tools
      mount API::V2::Management::Otp
      mount API::V2::Management::Documents
      mount API::V2::Management::ServiceAccounts

      add_swagger_documentation base_path: '/api/v2/management',
      info: {
        title: 'Barong',
        description: 'Management API for barong OAuth server'
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
        API::V2::Entities::Label,
        API::V2::Entities::APIKey,
        API::V2::Entities::UserWithFullInfo,
        API::V2::Entities::User,
        Entities::Profile,
        Entities::Phone,
        Entities::Document,
        Entities::UserWithProfile,
        Entities::UserWithKYC,
      ],
      api_version: 'v2',
      doc_version: Barong::Application::GIT_TAG,
      hide_format: true,
      hide_documentation_path: true,
      mount_path: '/management.json'
    end
  end
end
