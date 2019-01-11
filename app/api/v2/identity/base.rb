# frozen_string_literal: true

module API::V2
  module Identity
    class Base < Grape::API

      helpers API::V2::Identity::Utils

      do_not_route_options!
      # Enable Rails sessions

      rescue_from(ActiveRecord::RecordNotFound) do |_e|
        error!('Record is not found', 404)
      end

      rescue_from(Grape::Exceptions::ValidationErrors) do |error|
        error!(error.message, 400)
      end

      rescue_from(JWT::DecodeError) do |error|
        error!("Failed to decode and verify JWT", 403)
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
