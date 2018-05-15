# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  prepend_before_action :otp_verify, if: :otp_enabled?, only: :create

  def confirm
    return redirect_to(action: :new) if resource_params[:email].blank?

    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    @otp_enabled = otp_enabled?
    render action: :confirm
  end

private

  def otp_enabled?
    account_by_email&.otp_enabled
  end

  def otp_verify
    return if Vault::TOTP.validate?(account_by_email.uid, params[:otp])

    set_flash_message! :alert, :wrong_otp_code
    redirect_to accounts_sign_in_confirm_path
  rescue Vault::HTTPClientError => e
    redirect_to new_account_session_path, alert: "Vault error: #{e.errors.join}"
  end

  def account_by_email
    Account.kept.find_by_email(resource_params[:email])
  end
end
