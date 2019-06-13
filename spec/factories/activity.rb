# frozen_string_literal: true

FactoryBot.define do
  factory :activity do
    user { FactoryBot.create(:user) }
    user_ip { Faker::Internet.ip_v4_address }
    user_agent { Faker::Internet.user_agent }
    category {  %w[admin user].sample }
    topic { %w[session password otp account].sample }
    action { %w[otp::enable login logout signup].sample }
    result { %w[succeed failed].sample }
    data { {data: Faker::Lorem.sentence(3, true, 4)}.to_json }
  end
end
