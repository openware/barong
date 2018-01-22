# frozen_string_literal: true

module Admin
  class AccountsController < ModuleController

    def index
      @accounts = Account.page(params[:page])
    end

    def destroy
      return if params[:id] == current_user.id.to_s
      Account.find(params[:id]).destroy!
      respond_to do |format|
        format.html { redirect_to admin_accounts_url, notice: 'Successfully destroyed.' }
      end
    end

    def edit
      @account = Account.find(params[:id])
    end

    def update
      Account.find(params[:id]).update!(account_params)
      redirect_to admin_accounts_url
    end

  private

    def account_params
      params.require(:account).permit(:role)
    end

  end
end
