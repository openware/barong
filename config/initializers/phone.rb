require_dependency 'barong/mock_sms'

Barong::App.define do |config|
  config.set(:barong_twilio_service, 'sms')
  config.write(:barong_twilio_provider, TwilioSmsSendService)

  config.set(:barong_twilio_phone_number, '+15005550000')
  config.set(:barong_twilio_account_sid, '')
  config.set(:barong_twilio_auth_token, '')
  config.set(:barong_twilio_service_sid, '')
  config.set(:barong_sms_content_template, 'Your verification code for Barong: {{code}}')
end

sid = Barong::App.config.barong_twilio_account_sid
token = Barong::App.config.barong_twilio_auth_token
service_sid = Barong::App.config.barong_twilio_service_sid

if sid == '' || token == ''
  if Rails.env.production?
    Rails.logger.fatal('No Twilio sid or token')
    raise 'FATAL: Twilio setup is invalid'
  end
  client = Barong::MockSMS.new(sid, token)
  Barong::App.write(:barong_twilio_provider, TwilioSmsSendService)
elsif Barong::App.config.barong_twilio_service == 'verify'
  client = Twilio::REST::Client.new(sid, token)
  service = client.verify.services.create(friendly_name: Barong::App.config.app_name) unless service_sid.present?
  Barong::App.write(:barong_twilio_provider, TwilioVerifyService)
else
  client = Twilio::REST::Client.new(sid, token)
  Barong::App.write(:barong_twilio_provider, TwilioSmsSendService)
end

Barong::App.set(:barong_twilio_client, client) if client
Barong::App.set(:barong_twilio_service_sid, service.sid) if service
Phonelib.strict_check = true
