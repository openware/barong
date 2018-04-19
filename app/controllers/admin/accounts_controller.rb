# frozen_string_literal: true

module Admin
  class AccountsController < ModuleController
    def index
      @accounts = Account.page(params[:page])
    end

    def edit
      @account = Account.find(params[:id])
      @roles = %w[admin compliance member]
    end

    def update
      Account.find(params[:id]).update!(account_params)
      redirect_to admin_accounts_url
    end

    def destroy
      Account.find(params[:id]).destroy!
      respond_to do |format|
        format.html { redirect_to admin_accounts_url, notice: 'Successfully destroyed.' }
      end
    end

  private

    def account_params
      params.require(:account).permit(:role)
    end
  end
end
