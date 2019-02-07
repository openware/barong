# frozen_string_literal: true

module API
  module V2
    module Identity
      # base api configurations for module
      class Base < Grape::API
        helpers API::V2::Identity::Utils

        do_not_route_options!

        rescue_from(ActiveRecord::RecordNotFound) do |_e|
          error!({ errors: ['record.not_found'] }, 404)
        end

        rescue_from(Grape::Exceptions::ValidationErrors) do |error|
          # FIXME: grape exceptions
          error!(error.message, 400)
        end

        rescue_from(JWT::DecodeError) do |error|
          error!({ errors: ['jwt.decode_and_verify'] }, 403)
        end

        rescue_from(:all) do |error|
          Rails.logger.error "#{error.class}: #{error.message}"
          error!('Something went wrong', 500)
        end

        mount Identity::General
        mount Identity::Sessions
        mount Identity::Users
      end
    end
  end
end
