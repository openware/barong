# frozen_string_literal: true

class PhonesController < ApplicationController
  before_action :authenticate_account!

  def new
    if current_account.level < 1
      redirect_to index_path
    else
      @phone = Phone.new
    end
  end

  def create
    number = Phonelib.parse(phone_params[:number]).sanitized
    unless session[:phone] == number
      redirect_to new_phone_url, notice: 'Confirmation code was sent to another number'
      return
    end

    phone = Phone.new \
      account_id:                  current_account.id,
      number:                      number,
      verification_code:           session[:verif_code],
      submitted_verification_code: phone_params[:code]

    if phone.save
      current_account.level_set(:phone)
      redirect_to new_profile_path
    else
      redirect_to new_phone_url, notice: 'Phone verification failed'
    end
  end

  def verify
    sanitized_number = Phonelib.parse(phone_params[:number]).sanitized
    if Phone.exists?(number: sanitized_number)
      render json: { error: 'This phone was already verified' }, status: :unprocessable_entity
      return
    end

    number = Phonelib.parse(phone_params[:number]).international
    phone = Phone.new(account_id: current_account.id, number: number)

    if phone.validate
      set_session(sanitized_number, phone.generate_code)
      send_verification_code(phone)
      render json: { success: 'Code was sent' }
    else
      render json: { error: phone.errors.full_messages }, status: :unprocessable_entity
    end
  rescue Twilio::REST::TwilioError
    return render json: { error: 'Twillio service is unavailable now. Try later.' }, status: :unprocessable_entity
  end

private

  def send_verification_code(phone)
    app_name = ENV.fetch('APP_NAME', 'Barong')
    phone.send_sms("Your verification code for #{app_name}: #{session[:verif_code]}")
    Rails.logger.info("Sending SMS to #{phone.number} with code #{session[:verif_code]}")
  end

  def set_session(number, code)
    session[:phone] = number
    session[:verif_code] = code
  end

  def phone_params
    params.permit(:number, :code)
  end

end
