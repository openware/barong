# frozen_string_literal: true

class SecurityController < ApplicationController
  before_action :check_otp_enabled, only: :enable

  def enable
    @otp = Vault::TOTP.create(current_account.uid, current_account.email)
    @otp_secret = Vault::TOTP.otp_secret(@otp)
  end

  def confirm
    return redirect_to index_path unless current_account.otp_enabled
    render action: :confirm
  end

  def validate_otp
    if Vault::TOTP.validate?(current_account.uid, params[:otp])
      redirect_to index_path
    else
      render security_confirm_path, alert: 'Code is invalid'
    end
  end

  private

  def check_otp_enabled
    if current_account.opt_enabled
      redirect_to(index_path, alert: 'You are already enabled 2FA')
    end   
  end

  def otp_verify
    return if Vault::TOTP.validate?(current_account.uid, params[:otp])

    set_flash_message! :alert, :wrong_otp_code
    redirect_to accounts_sign_in_confirm_path
  rescue Vault::HTTPClientError => e
    redirect_to new_account_session_path, alert: "Vault error: #{e.errors.join}"
  end
end
