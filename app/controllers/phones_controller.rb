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
    begin
      code = phone_params[:code]
      number = '+' + phone_params[:country_code] + phone_params[:number]

      return redirect_to new_phone_url, notice: 'Confirmation code was sent to another number' \
      unless session[:phone] == number

      phone = Phone.new(account_id: current_account.id, number: number)
      phone.validate!
      phone.validate_code!(code, session[:verif_code])
      current_account.level_set(:phone)
      phone.save!

    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      return redirect_to new_phone_url, alert: 'Phone verification failed. Number is invalid or was already verified'
    end

    redirect_to new_profile_path
  end

  def verify
    begin
      number = phone_params[:number].delete(' ')

      return render status: :bad_request, json: { error: 'This phone number has already been used' } \
      if Phone.exists?(number: number)

      phone = Phone.new(account_id: current_account.id, number: number)
      phone.validate!
      session[:phone] = number
      session[:verif_code] = phone.generate_code

      Rails.logger.info("Sending SMS to %s with code %s" %
                        [phone.number, session[:verif_code]])

      app_name = ENV.fetch('APP_NAME', 'Barong')

      phone.send_sms("Your verification code for #{app_name}: #{session[:verif_code]}")

    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      return render status: :bad_request, json: { error: 'Phone is invalid' }
    end

    render json: { success: 'Code was sent' }
  end

  private

  def phone_params
    params.permit(:country_code, :number, :code)
  end

end
