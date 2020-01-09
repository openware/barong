# frozen_string_literal: true

# twilio sms sender
class TwilioSmsSendService
  class << self
    def send_confirmation(phone, _channel)
      Rails.logger.info("Sending SMS to #{phone.number}")

      send_sms(number: phone.number,
               content: Barong::App.config.sms_content_template.gsub(/{{code}}/, phone.code))
    end

    def send_sms(number:, content:)
      from_phone = Barong::App.config.twilio_phone_number
      client = Barong::App.config.twilio_client
      client.messages.create(
        from: from_phone,
        to:   '+' + number,
        body: content
      )
    end

    # returns true if given code matches number in DB
    def verify_code?(number:, code:, user:)
      user.phones.find_by(number: number, code: code).present?
    end
  end
end
