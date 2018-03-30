# frozen_string_literal: true

class PhonesController < ApplicationController
  include PhoneUtils
  before_action :authenticate_account!

  def new
    if current_account.level < 1
      redirect_to index_path
    else
      @phone = Phone.new
    end
  end

  def create
    number = PhoneUtils.sanitize(phone_params[:country_code] + phone_params[:number])
    return redirect_to new_phone_url, notice: 'Confirmation code was sent to another number'\
    unless session[:phone] == number
    phone = Phone.new \
      account_id:                  current_account.id,
      number:                      number,
      verification_code:           session[:verif_code],
      submitted_verification_code: phone_params[:code]
    if phone.save
      current_account.level_set(:phone)
      redirect_to new_profile_path
    else
      redirect_to new_phone_url, alert: 'Phone verification failed. Number is invalid or was already verified'
    end
  end

  def verify
    number = PhoneUtils.sanitize(phone_params[:number])
    phone = Phone.new(account_id: current_account.id, number: number)

    return render json: { error: 'Phone has already been used' } if phone.number_exists?

    if PhoneUtils.valid?(phone.number)
      save_session(phone)
      Rails.logger.info("Sending SMS to #{phone.number} with code #{session[:verif_code]}")
      app_name = ENV.fetch('APP_NAME', 'Barong')
      phone.send_sms("Your verification code for #{app_name}: #{session[:verif_code]}")
      render json: { success: 'Code was sent' }
    else
      render json: { error: 'Phone is invalid' }
    end
  end

private

  def save_session(phone)
    session[:phone] = phone.number
    session[:verif_code] = phone.generate_code
  end

  def phone_params
    params.permit(:country_code, :number, :code)
  end

end
