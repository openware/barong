# frozen_string_literal: true

module Admin
  class ModuleController < ApplicationController
    layout 'admin'

    alias current_user current_account # CanCanCan expects current_user.

    rescue_from CanCan::AccessDenied, with: :redirect_to_index

    class << self
      def inherited(klass)
        klass.instance_eval do
          controller_name = klass.name.demodulize.underscore.singularize

          if controller_name == 'dashboard_controller'
            load_and_authorize_resource class: false
          else
            load_and_authorize_resource
          end
        end
      end
    end

    def redirect_to_index
      redirect_to new_account_session_url
    end

  end
end
