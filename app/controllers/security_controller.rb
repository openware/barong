# frozen_string_literal: true

#
# SecurityController
#
class SecurityController < ApplicationController

  # GET /security
  def enable
    @otp = Vault::TOTP.safe_create(current_account.uid, current_account.email)

    if @otp.nil?
      redirect_to(index_path, alert: 'You already have created your OTP key')
      return
    end

    @otp_secret = CGI.parse(URI.parse(@otp.data[:url]).query)['secret'][0]
  end

  def confirm
    return redirect_to index_path unless otp_enabled?

    render action: :confirm
  end

  def validate_otp
    if Vault::TOTP.validate?(current_account.uid, params[:otp])
      redirect_to index_path
    else
      Vault.logical.delete("totp/keys/#{current_account.uid}")
      render  security_confirm_path, alert: 'err'
    end
  end

private

  def otp_enabled?
    uid = current_account.uid
    return false unless uid.present?
    Vault::TOTP.exist?(uid)
  end

  def otp_verify
    return if Vault::TOTP.validate?(find_uid_by_params_email, params[:otp])

    set_flash_message! :alert, :wrong_otp_code
    redirect_to accounts_sign_in_confirm_path
  rescue Vault::HTTPClientError => e
    redirect_to new_account_session_path, alert: "Vault error: #{e.errors.join}"
  end

end
