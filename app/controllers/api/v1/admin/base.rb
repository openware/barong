# frozen_string_literal: true

module API
  module V1
    module Admin
      class Base < API::Base
        format :json
        helpers do
          def authorize!(*args)
            @current_account = Account.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
            Ability.new(@current_account).authorize!(*args)
          end
        end

        mount API::V1::Admin::Accounts => '/admin'
        mount API::V1::Admin::Profiles => '/admin'
        mount API::V1::Admin::Documents => '/admin'
        mount API::V1::Admin::Applications => '/admin'
        mount API::V1::Admin::Websites => '/admin'

        route :any, '*path' do
          raise StandardError, 'Unable to find endpoint'
        end

      end
    end
  end
end
