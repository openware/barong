# frozen_string_literal: true

require_dependency 'phone_utils'

class PhonesController < ApplicationController
  before_action :authenticate_account!
  before_action :check_account_level
  before_action :check_phone, only: :create
  before_action :check_code, only: :create

  rescue_from Twilio::REST::RestError, with: :twilio_errors

  def new
    @phone = Phone.new
  end

  def create
    if current_account.phones.create(number: @phone_number,
                                     validated_at: Time.current)
      current_account.level_set(:phone)
      redirect_to new_profile_path
    else
      flash.now[:alert] = 'Phone verification failed. Number is invalid or was already verified'
      render :new
    end
  end

  def verify
    number = PhoneUtils.sanitize(phone_params[:number])
    phone = current_account.phones.new(number: number)
    return render json: { error: 'Phone has already been used' } if Phone.exists?(number: number)

    if PhoneUtils.valid?(phone.number)
      save_session(phone)
      send_confirmation_sms(phone)
      render json: { success: 'Code was sent' }
    else
      render json: { error: 'Phone is invalid' }
    end
  end

private

  def send_confirmation_sms(phone)
    code = session[:verif_code]
    Rails.logger.info("Sending SMS to #{phone.number} with code #{code}")

    app_name = ENV.fetch('APP_NAME', 'Barong')
    PhoneUtils.send_sms(number: phone.number,
                        content: "Your verification code for #{app_name}: #{code}")
  end

  def check_account_level
    redirect_to index_path if current_account.level < 1
  end

  def check_phone
    @phone_number = extract_phone_number_from_params
    return if session[:phone] == @phone_number

    flash.now[:alert] = 'Confirmation code was sent to another number'
    render :new
  end

  def check_code
    return if PhoneUtils.verify_code(server_code: session[:verif_code],
                                     user_code: phone_params[:code])

    flash.now[:alert] = 'Verification code is invalid'
    render :new
  end

  def extract_phone_number_from_params
    country_code = phone_params.fetch(:country_code, '')
    number = phone_params.fetch(:number, '')
    PhoneUtils.sanitize(country_code + number)
  end

  def save_session(phone)
    session[:phone] = phone.number
    session[:verif_code] = phone.generate_code
  end

  def phone_params
    params.permit(:country_code, :number, :code)
  end

  def twilio_errors(exception)
    Rails.logger.error "Twilio Client Error: #{exception.message}"
    render json: { error: 'Something wrong with Twilio Client' }
  end
end
