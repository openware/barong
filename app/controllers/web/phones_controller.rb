# frozen_string_literal: true

module Web
  class PhonesController < ModuleController

    def index
      @phones = current_account.phones
    end

    def new
      @phone = Phone.new
    end

    def create
      number = params[:number]
      return redirect_to new_phone_url, notice: 'Sorry, phone number is invalid'\
      unless Phonelib.parse(number).valid?
      return redirect_to new_phone_url, notice: 'Sorry, wrong code'\
      unless code_matches
      @phone = Phone.new(number: number)
      ph = Phonelib.parse(number)
      @phone.update!(country: ph.country, account_id: current_account.id)
      redirect_to phones_path
    end

    def verify
      return render json: { error: 'Phone is invalid' } unless Phonelib.parse(params[:number]).valid?
      send_sms(params[:number])
      render json: { success: 'Code was sent' }
    end

  private

    def code_matches
      params[:code] == session[:verif_code]
    end

    def verif_code
      session[:verif_code] = rand.to_s[2..6]
    end

    def send_sms(number)
      sid = Rails.application.secrets.twilio_account_sid
      token = Rails.application.secrets.twilio_auth_token
      @client = Twilio::REST::Client.new(sid, token)
      @client.messages.create(
        from: Rails.application.secrets.twilio_phone_number,
        to:   number,
        body: verif_code
      )
    end
  end
end
