# frozen_string_literal: true

Twilio::REST::Client = FakeSMS if Rails.env.test?
