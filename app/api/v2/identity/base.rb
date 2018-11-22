# frozen_string_literal: true

module API::V2
  module Identity
    class Base < Grape::API
      cascade false

      format         :json
      content_type   :json, 'application/json'
      default_format :json

      helpers API::V2::Identity::Utils

      do_not_route_options!
      # Enable Rails sessions
      use ActionDispatch::Session::CookieStore

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

      route :any, '*path' do
        error! 'Route is not found', 404
      end
    end
  end
end
