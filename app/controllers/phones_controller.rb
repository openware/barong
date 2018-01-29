# frozen_string_literal: true

class PhonesController < ApplicationController

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

      phone = Phone.new(account_id: current_account.id, number: number)
      phone.validate!
      phone.validate_code!(code, session[:verif_code])
      current_account.level_set(:phone)
      phone.save!

    rescue ActiveRecord::RecordInvalid => invalid
      return redirect_to new_phone_url, notice: 'Phone verification failed'
    end

    redirect_to new_profile_path
  end

  def verify
    begin
      number = phone_params[:number]
      phone = Phone.new(account_id: current_account.id, number: number)
      phone.validate!
      session[:verif_code] = phone.generate_code
      Rails.logger.info("Sending SMS to %s with code %s" %
                        [phone.number, session[:verif_code]])
      app_name = ENV.fetch('APP_NAME', 'Barong')
      phone.send_sms("Your verification code for #{app_name}: #{session[:verif_code]}")

    rescue ActiveRecord::RecordInvalid => invalid
      return render json: { error: 'Phone is invalid' }
    end

    render json: { success: 'Code was sent' }
  end

  private

  def phone_params
    params.permit(:country_code, :number, :code)
  end

end
