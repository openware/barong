# frozen_string_literal: true

module Admin
  class AccountsController < ModuleController

    def index
      @accounts = Account.all.page params[:page]
    end

    def destroy
      Account.find(params[:id]).destroy!
      respond_to do |format|
        format.html { redirect_to admin_accounts_url, notice: 'Successfully destroyed.' }
      end
    end

    def edit
      @account = Account.find(params[:id])
    end

    def update
      @account = Account.find(params[:id])
      @account.update_attributes(account_params) if params[:account]
      redirect_to admin_accounts_path
    end

  private

    def account_params
      params.require(:account).permit(:role)
    end

  end
end
