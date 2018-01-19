# frozen_string_literal: true

module Api
  class AccountsController < ModuleController
    before_action :doorkeeper_authorize!

    def index
      @accounts = Account.all
      respond_with @accounts
    end
  end
end
