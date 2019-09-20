# frozen_string_literal: true

# twilio process verification
class TwilioVerifyService
  class << self
    def send_confirmation(phone, channel)
      Rails.logger.info("Sending code to #{phone.number} via #{channel}")

      send_code(number: phone.number, channel: channel)
    end

    def send_code(number:, channel:)
      verify_client.services(@service_sid)
                   .verifications
                   .create(to: '+' + number, channel: channel)
    end

    def verify_code(number:, code:, user:)
      verify_client.services(@service_sid)
                   .verification_checks
                   .create(to: '+' + number, code: code)
    end

    def verify_client
      client = Barong::App.config.barong_twilio_client
      @service_sid = Barong::App.config.barong_twilio_service_sid

      client.verify
    end
  end
end
