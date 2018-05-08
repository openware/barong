# frozen_string_literal: true

module Admin
  class AccountsController < ModuleController
    before_action :find_account, except: :index

    def index
      @accounts = Account.kept.page(params[:page])
    end

    def edit
      @roles = %w[admin compliance member]
    end

    def update
      @account.update!(account_params)
      redirect_to admin_accounts_url
    end

    def destroy
      @account.discard
      respond_to do |format|
        format.html { redirect_to admin_accounts_url, notice: 'Account is marked as discarded' }
      end
    end

  private

    def find_account
      @account = Account.kept.find(params[:id])
    end

    def account_params
      params.require(:account).permit(:role)
    end
  end
end
