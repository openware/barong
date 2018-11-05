
require_dependency 'barong/mock_sms'

if !Rails.env.production?
  Twilio::REST::Client = Barong::MockSMS
end

Phonelib.strict_check = true
