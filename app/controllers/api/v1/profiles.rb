# frozen_string_literal: true

require_dependency 'doorkeeper/grape/helpers'

module API
  module V1
    class Profiles < Grape::API
      format :json
      content_type   :json, 'application/json'
      default_format :json

      helpers Doorkeeper::Grape::Helpers

      before do
        doorkeeper_authorize!

        def current_account
          @current_account = Account.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
        end
      end

      desc 'Profile related routes'
      resource :profile do
        desc 'Return profile of current resource owner'
        get '/' do
          present current_account.profile, with: API::Entities::Profile
        end
      end
    end
  end
end
