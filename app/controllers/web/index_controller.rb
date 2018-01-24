# frozen_string_literal: true

module Web
  class IndexController < ModuleController
    def index
      if current_account.present?
        if current_account.role == "admin"
          redirect_to admin_dashboard_path
        elsif current_account.status == false && current_account.verified == false
          redirect_to edit_account_path(current_account)
        end
      end
    end
  end
end
