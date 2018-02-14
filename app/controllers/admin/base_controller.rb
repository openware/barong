# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    layout 'admin'

    alias current_user current_account # CanCanCan expects current_user.

    rescue_from CanCan::AccessDenied, with: :redirect_to_index

  private

    def redirect_to_index
      redirect_to new_account_session_url
    end
  end
end
