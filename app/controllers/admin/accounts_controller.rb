# frozen_string_literal: true

module Admin
  class AccountsController < ModuleController
    before_action :find_account, except: %i[index]

    def index
      @accounts = Account.page(params[:page])
    end

    def show
      @profile = @account.profile
      @documents = @account.documents
      @labels = @account.labels
      @phones = @account.phones
      @document_label_value = @profile.account
                                      .labels
                                      .find_by(key: 'document', scope: 'private')
                                      &.value
    end

    def edit
    end

    def update
      @account.update!(account_params)
      redirect_to admin_accounts_url
    end

    def destroy
      @account.destroy!
      respond_to do |format|
        format.html { redirect_to admin_accounts_url, notice: 'Successfully destroyed.' }
      end
    end

  private

    def find_account
      @account = Account.find(params[:id])
    end

    def account_params
      params.require(:account).permit(:role)
    end
  end
end
