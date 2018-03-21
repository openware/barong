# frozen_string_literal: true

class SessionsController < Devise::SessionsController

  prepend_before_action :otp_verify, if: :otp_enabled?, only: :create

  def confirm
    if resource_params[:email].nil?
      redirect_to action: :new
      return
    end

    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    @otp_enabled = otp_enabled?

    render action: :confirm
  rescue Vault::HTTPClientError => e
    respond_with resource, alert: e.errors
  end

private

  def otp_enabled?
    current_account&.otp_enabled
  end

  def otp_verify
    return if Vault::TOTP.validate?(current_account&.uid, params[:otp])

    set_flash_message! :alert, :wrong_otp_code
    redirect_to accounts_sign_in_confirm_path
  rescue Vault::HTTPClientError => e
    redirect_to new_account_session_path, alert: "Vault error: #{e.errors.join}"
  end

  def current_account
    Account.find_by_email(resource_params[:email])
  end
end
