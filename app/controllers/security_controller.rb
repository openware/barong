# frozen_string_literal: true

class SecurityController < ApplicationController
  before_action :check_otp_enabled
  before_action :check_vault_availability

  def enable
    @otp = Vault::TOTP.create(current_account.uid, current_account.email)
    Rails.logger.debug { "Vault TOTP data #{@otp.inspect}" }
    @otp_secret = Vault::TOTP.otp_secret(@otp)
    Rails.logger.debug { "TOTP secret #{@otp_secret.inspect}" }
  end

  def confirm
    if Vault::TOTP.validate?(current_account.uid, params[:otp])
      status = current_account.update(otp_enabled: true)
      return redirect_to index_path, notice: '2FA is enabled' if status
      redirect_to security_path, alert: current_account.errors.full_messages.to_sentence
    else
      redirect_to security_path, alert: 'Code is invalid'
    end
  end

private

  def check_vault_availability
    return if Vault::TOTP.server_available?

    redirect_to index_path, alert: '2FA is disabled'
  end

  def check_otp_enabled
    return unless current_account.otp_enabled
    redirect_to(index_path, alert: '2FA has been enabled for this account')
  end
end
