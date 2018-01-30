class AccountsController < ApplicationController
  require 'rotp'

  def edit
    @account = current_account
  end

  def update
    @account = Account.find(current_account.id)
    render 'edit'
  end

  def disable_otp
    account = current_account
    account.otp_required_for_login = false
    account.otp_secret = ''
    account.save!
    redirect_to edit_accounts_path, notice: 'Two-factor authentication disabled'
  end

  def enable_otp
    account = current_account
    account.otp_required_for_login = true
    account.otp_secret = ROTP::Base32.random_base32
    account.save!
    redirect_to edit_accounts_path, notice: 'Two-factor authentication enabled'
  end
end