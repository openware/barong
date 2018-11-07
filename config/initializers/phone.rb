require_dependency 'barong/mock_sms'

Barong::App.define do |config|
  config.set(:twilio_phone_number, '+15005550000')
  config.set(:twilio_account_sid, '')
  config.set(:twilio_auth_token, '')
end

sid = Barong::App.config.twilio_account_sid
token = Barong::App.config.twilio_auth_token

if sid == '' || token == ''
  if Rails.env.production?
    Rails.logger.fatal('No Twilio sid or token')
    raise 'FATAL: Twilio setup is invalid'
  end
  client = Barong::MockSMS.new(sid, token)
else
  client = Twilio::REST::Client.new(sid, token)
end

Barong::App.define { |c| c.set(:sms_sender, client) }
Phonelib.strict_check = true

