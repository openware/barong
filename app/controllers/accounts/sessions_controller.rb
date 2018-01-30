# frozen_string_literal: true

require 'rotp'

class Accounts::SessionsController < Devise::SessionsController
  def create
    unless verified_2fa
      redirect_to index_path, notice: 'Wrong One Time Password!'
      return
    end

    auth_options = { :recall => '#{controller_path}#index', :scope => resource_name }
    resource = warden.authenticate!(auth_options)

    set_flash_message(:notice, :signed_in)
    sign_in_and_redirect(resource_name, resource)
  end

  private

  def verified_2fa
    p params
    account = Account.find_by_email(params[:account][:email])
    otp = params[:account][:otp_secret]
    totp = ROTP::TOTP.new(account.otp_secret)
    account.otp_required_for_login ? totp.verify(otp) : true
  end
end
