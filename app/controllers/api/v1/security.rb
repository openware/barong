# frozen_string_literal: true

require_dependency 'doorkeeper/grape/helpers'
require_dependency 'barong/security/access_token'

module API
  module V1
    class Security < Grape::API
      format :json
      content_type   :json, 'application/json'
      default_format :json

      helpers Doorkeeper::Grape::Helpers

      before do
        doorkeeper_authorize!

        def current_account_id
          doorkeeper_token.resource_owner_id
        end

        def current_application
          doorkeeper_token.application
        end
      end

      desc 'Security related routes'
      resource :security do
        desc 'Renews JWT if current JWT is valid'
        post '/renew' do
          # expiration time will be specified by the request param or taken from ENV, if both are nil, it will be 4 hours
          Barong::Security::AccessToken.create params[:expires_in], current_account_id, current_application
        end
      end
    end
  end
end
