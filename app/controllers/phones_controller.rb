# frozen_string_literal: true

class PhonesController < ApplicationController

  def new
    @phone = Phone.new
  end

  def create
    begin
      code = phone_params[:code]
      number = '+' + phone_params[:country_code] + phone_params[:number]

      phone = Phone.new(account_id: current_account.id, number: number)
      phone.validate!
      phone.validate_code!(code, session[:verif_code])
      phone.save!

    rescue ActiveRecord::RecordInvalid => invalid
      return redirect_to new_phone_url, notice: 'Phone verification failed'
    end

    current_account.increase_level
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
      phone.send_sms(session[:verif_code])

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
