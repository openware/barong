# frozen_string_literal: true

module Accounts
  class ConfirmationsController < Devise::ConfirmationsController

    # POST /resource/confirmation
    def create
      Rails.cache.write("confirmation_instructions_#{resource_params[:email]}_domain", request.domain)
      super
    end

  end
end
