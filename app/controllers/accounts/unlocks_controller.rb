# frozen_string_literal: true

module Accounts
  class UnlocksController < Devise::UnlocksController

    # POST /resource/unlock
    def create
      Rails.cache.write("unlock_instructions_#{resource_params[:email]}_domain", request.domain)
      super
    end

  end
end
