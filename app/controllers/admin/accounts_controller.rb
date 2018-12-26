# frozen_string_literal: true

module Admin
  class AccountsController < ModuleController
    before_action :find_account, except: :index

    def index
      if params[:level]
        @accounts = Account.where(level: params[:level]).kept.page(params[:page])
      elsif params[:state]
        @accounts = Account.where(state: params[:state]).kept.page(params[:page])
      else
        @accounts = Account.kept.page(params[:page])
      end
    end

    def show
      @profile = @account.profile
      @documents = @account.documents
      @labels = @account.labels
      @phones = @account.phones
      @document_label_value = document_label&.value
    end

    def edit
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

    def disable_2fa
      @account.update!(otp_enabled: false)
      redirect_to action: :show
    end

  private

    def find_account
      @account = Account.kept.find(params[:id])
    end

    def document_label
      @account.labels.find_by(key: 'document', scope: 'private')
    end

    def account_params
      params.require(:account).permit(:role, :state)
    end
  end
end
