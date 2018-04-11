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
    unless session[:phone] == number
      return redirect_to new_phone_url, notice: 'Confirmation code was sent to another number'
    end

    phone = Phone.new(account_id: current_account.id,
                      number: number,
                      verification_code: session[:verif_code],
                      submitted_verification_code: phone_params[:code],
                      validated_at: Time.current)

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
      PhoneUtils.send_confirmation_sms(phone)
      render json: { success: 'Code was sent' }
    else
      render json: { error: 'Phone is invalid' }
    end
  end

private

  def save_session(phone)
    session[:phone] = phone.number
    session[:verif_code] = phone.code
  end

  def phone_params
    params.permit(:country_code, :number, :code)
  end

end
