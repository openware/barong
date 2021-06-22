module API::V2
  module Management
    class Base < Grape::API
      PREFIX = '/management'

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
      mount API::V2::Management::APIKeys

      add_swagger_documentation base_path: File.join(API::Base::PREFIX, API::V2::Base::API_VERSION, 'barong', PREFIX),
                                info: {
                                  title: 'Barong',
                                  description: 'Management API for barong OAuth server'
                                },
                                mount_path:  '/swagger',
                                security_definitions: {
                                  'SecurityScope': {
                                    description: 'JWT should have signature keychains',
                                    type: 'basic',
                                    name: 'Authorization'
                                  }
                                },
                                models: [
                                  API::V2::Entities::Label,
                                  API::V2::Entities::APIKey,
                                  API::V2::Entities::UserWithFullInfo,
                                  API::V2::Entities::User,
                                  API::V2::Management::Entities::Profile,
                                  API::V2::Management::Entities::Phone,
                                  API::V2::Management::Entities::Document,
                                  API::V2::Management::Entities::UserWithProfile,
                                  API::V2::Management::Entities::UserWithKYC,
                                  API::V2::Management::Entities::APIKey,
                                ],
                                api_version: API::V2::Base::API_VERSION,
                                doc_version: Barong::Application::GIT_TAG,
                                add_base_path: true
    end
  end
end
