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

end
