class AccountsController < ApplicationController
  def disable_otp
    current_account.otp_required_for_login = false
    current_account.save!
    redirect_to index_path
  end

  def enable_otp
    current_account.otp_secret = Account.generate_otp_secret
    current_account.otp_required_for_login = true
    current_account.save!
    redirect_to index_path
  end
end