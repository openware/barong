# frozen_string_literal: true

module UserApi
  module V1
    class DeviceActivityMiddleware < Grape::Middleware::Base
      def before
        p request
      end

      private

      def request
        @request ||= Grape::Request.new(env)
      end
    end
  end
end
