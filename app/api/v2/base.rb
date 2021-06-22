# frozen_string_literal: true

require_dependency 'v2/validations'
require_dependency 'v2/exception_handlers'

module API::V2
  # Base api configuration for V2 module
  class Base < Grape::API
    API_VERSION = 'v2'

    cascade false

    logger Rails.logger.dup
    if Rails.env.production?
      logger.formatter = GrapeLogging::Formatters::Json.new
    else
      logger.formatter = GrapeLogging::Formatters::Rails.new
    end
    use GrapeLogging::Middleware::RequestLogger,
        logger:    logger,
        log_level: (Rails.env.production?)? :warn : :debug,
        include:   [GrapeLogging::Loggers::Response.new,
                    GrapeLogging::Loggers::FilterParameters.new,
                    GrapeLogging::Loggers::ClientEnv.new,
                    GrapeLogging::Loggers::RequestHeaders.new]

    helpers API::V2::Utils

    format         :json
    content_type   :json, 'application/json'
    default_format :json

    include ExceptionHandlers

    mount Identity::Base   => '/identity'
    mount Public::Base     => '/public'
    mount Resource::Base   => '/resource'

    add_swagger_documentation base_path: File.join(API::Base::PREFIX, API_VERSION, 'barong'),
                              add_base_path: true,
                              info: {
                                title: 'Barong',
                                description: 'RESTful API for barong OAuth server'
                              },
                              models: [
                                API::V2::Entities::Level,
                                API::V2::Entities::Label,
                                API::V2::Entities::APIKey,
                                API::V2::Entities::Profile,
                                API::V2::Entities::User,
                                API::V2::Entities::UserWithProfile,
                                API::V2::Entities::UserWithKYC,
                                API::V2::Entities::UserWithFullInfo,
                                API::V2::Entities::Phone,
                                API::V2::Entities::Activity,
                                API::V2::Entities::ServiceAccounts,
                                API::V2::Entities::Document,
                                API::V2::Entities::DataStorage,
                                API::V2::Entities::Comment,
                                API::V2::Entities::AdminLabelView
                              ],
                              api_version: API_VERSION,
                              doc_version: Barong::Application::GIT_TAG,
                              mount_path: '/swagger'

    mount Management::Base => '/management'
    mount Admin::Base      => '/admin'

    route :any, '*path' do
      error! 'Route is not found', 404
    end
  end
end
