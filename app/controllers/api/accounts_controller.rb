# frozen_string_literal: true

module Api
  class AccountsController < ModuleController
    before_action :doorkeeper_authorize!

    def show
      render json: current_resource_owner.as_json(only: %i[email level role state])
    end

    def current_resource_owner
      Account.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end
  end
end
