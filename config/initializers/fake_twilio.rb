if Rails.env.test?
  Twilio::REST::Client = FakeSMS
end
