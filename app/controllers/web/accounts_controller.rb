# frozen_string_literal: true

module Web
  class AccountsController < ModuleController
  before_action :load_account, only: [:show, :edit, :update]

  def update
    @account.update(account_params)
    redirect_to account_path(current_account)
  end

  private

    def load_account
      @account = Account.find_by(id: params[:id])
    end

    def account_params
      params.require(:account).permit(:role, :real_name, :birth_date, :address, :city, :country, :zipcode, :document_type, :document_number, :doc_photo, :residence_proof, :residence_photo, :verified, :status)
    end
  end
end
