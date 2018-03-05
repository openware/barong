# frozen_string_literal: true

module Accounts
  class PasswordsController < Devise::PasswordsController

    # POST /resource/password
    def create
      Rails.cache.write("reset_password_instructions_#{resource_params[:email]}_domain", request.domain)
      super
    end

  end
end
