# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    class Profiles < Grape::API
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
          current_account.profile.as_json(only: %i[first_name last_name dob address city country state])
        end
      end
    end
  end
end
