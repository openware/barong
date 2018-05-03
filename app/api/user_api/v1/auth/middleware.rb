# frozen_string_literal: true

module UserApi
  module V1
    module Auth
      class Middleware < Grape::Middleware::Base
        def before
          return unless auth_by_jwt?

          env['user_api.v1.current_account_uid'] = \
            JWTAuthenticator.new(headers['Authorization']).authenticate!
        end

      private

        def auth_by_jwt?
          headers.key?('Authorization')
        end

        def request
          @request ||= Grape::Request.new(env)
        end

        def headers
          request.headers
        end
      end
    end
  end
end
