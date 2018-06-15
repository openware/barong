# frozen_string_literal: true

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
      current_account.add_level_label(:phone)
      redirect_to new_profile_path
    else
      flash.now[:alert] = 'Phone verification failed. Number is invalid or was already verified'
      render :new
    end
  end

  def verify
    number = PhoneUtils.international(phone_params[:number])
    phone = current_account.phones.new(number: number)
    return render json: { error: 'Phone has already been used' } if phone.number_exists?

    if PhoneUtils.valid?(phone.number)
      save_session(phone)
      PhoneUtils.send_confirmation_sms(phone)
      render json: { success: 'Code was sent' }
    else
      render json: { error: 'Phone is invalid' }
    end
  end

private

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
    PhoneUtils.international(country_code + number)
  end

  def save_session(phone)
    session[:phone] = phone.number
    session[:verif_code] = phone.code
  end

  def phone_params
    params.permit(:country_code, :number, :code)
  end

  def twilio_errors(exception)
    Rails.logger.error "Twilio Client Error: #{exception.message}"
    render json: { error: 'Something wrong with Twilio Client' }
  end
end
