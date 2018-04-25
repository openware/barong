if Rails.env.development?
  Twilio::REST::Client = FakeSMS
end
