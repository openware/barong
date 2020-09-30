# frozen_string_literal: true

# twilio sms sender
class MockPhoneVerifyService
  class << self
    def send_confirmation(phone, _channel)
      Rails.logger.info("Sending SMS to #{phone.number}")

      send_sms(number: phone.number,
               content: Barong::App.config.sms_content_template.gsub(/{{code}}/, phone.code))
    end

    def send_sms(number:, content:)
      from_phone = Barong::App.config.twilio_phone_number
      client = Barong::MockSMS.new('', '')
      client.messages.create(from: from_phone, to: '+' + number, body: content)
    end

    # always return true
    def verify_code?(number:, code:, user:)
      user.phones.find_by_number(number).present?
    end
  end
end
