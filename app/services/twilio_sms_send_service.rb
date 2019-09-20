# frozen_string_literal: true

# twilio sms sender
class TwilioSmsSendService
  class << self
    def send_confirmation(phone, _channel)
      Rails.logger.info("Sending SMS to #{phone.number}")

      send_sms(number: phone.number,
               content: Barong::App.config.barong_sms_content_template.gsub(/{{code}}/, phone.code))
    end

    def send_sms(number:, content:)
      from_phone = Barong::App.config.barong_twilio_phone_number
      client = Barong::App.config.barong_twilio_client
      client.messages.create(
        from: from_phone,
        to:   '+' + number,
        body: content
      )
    end

    def verify_code(number:, code:, user:)
      if user.phones.find_by(number: number, code: code).present?
        OpenStruct.new(status: 'approved')
      else
        OpenStruct.new(status: 'not_found')
      end
    end
  end
end
