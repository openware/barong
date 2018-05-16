# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module UserApi
  module V1
    class AuthenticationMiddleware < Grape::Middleware::Base
      extend Memoist
      include Doorkeeper::Grape::Helpers

      def before
        env['user_api.account_id'] = doorkeeper_token&.resource_owner_id
      end

    private

      def request
        Grape::Request.new(env)
      end
      memoize :request
    end
  end
end
