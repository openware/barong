# frozen_string_literal: true

require_dependency 'barong/mock_sms'

Barong::App.define do |config|
  config.write(:barong_twilio_provider, TwilioSmsSendService)
  config.set(:barong_phone_verification, 'mock')

  config.set(:barong_twilio_phone_number, '+15005550000')
  config.set(:barong_twilio_account_sid, '')
  config.set(:barong_twilio_auth_token, '')
  config.set(:barong_twilio_service_sid, '')
  config.set(:barong_sms_content_template, 'Your verification code for Barong: {{code}}')
end

sid = Barong::App.config.barong_twilio_account_sid
token = Barong::App.config.barong_twilio_auth_token
service_sid = Barong::App.config.barong_twilio_service_sid

case Barong::App.config.barong_phone_verification
when 'twilio_sms'
  raise 'Invalid twilio config' if sid.to_s.empty? || token.to_s.empty?

  client = Twilio::REST::Client.new(sid, token)
  Barong::App.write(:barong_twilio_provider, TwilioSmsSendService)

when 'twilio_verify'
  raise 'Invalid twilio config' if sid.to_s.empty? || token.to_s.empty?

  client = Twilio::REST::Client.new(sid, token)
  service = client.verify.services.create(friendly_name: Barong::App.config.app_name) unless service_sid.present?
  Barong::App.write(:barong_twilio_provider, TwilioVerifyService)

when 'mock'
  if Rails.env.production?
    Rails.logger.fatal('mock phone verification service must not be used in production')
    raise 'FATAL: mock phone verification service must not be used in production'
  end
  client = Barong::MockSMS.new(sid, token)
  Barong::App.write(:barong_twilio_provider, TwilioSmsSendService)
else
  raise "Unknown phone verification service #{Barong::App.config.barong_phone_verification}"
end

Barong::App.set(:barong_twilio_client, client) if client
Barong::App.set(:barong_twilio_service_sid, service.sid) if service
Phonelib.strict_check = true
