# frozen_string_literal: true

module API::V2
  module Identity
    class Base < Grape::API
      version 'v2', using: :path

      cascade false

      format         :json
      content_type   :json, 'application/json'
      default_format :json

      # helpers API::V2::Helpers

      do_not_route_options!
      # Enable Rails sessions
      use ActionDispatch::Session::CookieStore

      helpers do
        def session
          request.session
        end
      end

      rescue_from(ActiveRecord::RecordNotFound) do |_e|
        error!('Record is not found', 404)
      end

      rescue_from(Grape::Exceptions::ValidationErrors) do |error|
        error!(error.message, 400)
      end

      rescue_from(:all) do |error|
        Rails.logger.error "#{error.class}: #{error.message}"
        error!('Something went wrong', 500)
      end

      mount Identity::General
      mount Identity::Sessions

      route :any, '*path' do
        error! 'Route is not found', 404
      end
    end
  end
end
