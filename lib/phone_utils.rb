# frozen_string_literal: true

#
# Module for validation phones
#
module PhoneUtils
  class << self
    def sanitize(unsafe_phone)
      unsafe_phone.to_s.gsub(/\D/, '')
    end

    def parse(unsafe_phone)
      Phonelib.parse sanitize(unsafe_phone)
    end

    def valid?(unsafe_phone)
      parse(unsafe_phone).valid?
    end

    def international(unsafe_phone)
      parse(unsafe_phone).international(false)
    end

    def send_confirmation_sms(phone)
      Rails.logger.info("Sending SMS to #{phone.number} with code #{phone.code}")

      sms_content = ENV.fetch('SMS_CONTENT', 'Your verification code')
      send_sms(number: phone.number,
               content: "#{sms_content}: #{phone.code}")
    end

    def send_sms(number:, content:)
      sid = Rails.application.secrets.twilio_account_sid
      token = Rails.application.secrets.twilio_auth_token
      from_phone = Rails.application.secrets.twilio_phone_number

      client = Twilio::REST::Client.new(sid, token)
      client.messages.create(
        from: from_phone,
        to:   '+' + number,
        body: content
      )
    end

    def verify_code(server_code:, user_code:)
      return false if server_code.blank?
      server_code == user_code
    end
  end
end
