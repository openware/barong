# frozen_string_literal: true

module Admin
  class ModuleController < ApplicationController
    layout 'admin'

    alias current_user current_account # CanCanCan expects current_user.

    rescue_from CanCan::AccessDenied, with: :redirect_to_index

    class << self
      def inherited(klass)
        klass.instance_eval do
          load_and_authorize_resource
        end
      end
    end

  private

    def redirect_to_index
      redirect_to new_account_session_url
    end
  end
end
