module API::V2
  module Management
    class Base < Grape::API

      logger Rails.logger.dup
      logger.formatter = GrapeLogging::Formatters::Rails.new
      use GrapeLogging::Middleware::RequestLogger,
          logger:    logger,
          log_level: :info,
          include:   [GrapeLogging::Loggers::Response.new,
                      GrapeLogging::Loggers::FilterParameters.new,
                      GrapeLogging::Loggers::ClientEnv.new,
                      GrapeLogging::Loggers::RequestHeaders.new]

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
      mount API::V2::Management::Tools
    end
  end
end
