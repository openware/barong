# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    email { Faker::Internet.email }
    password 'B@rong2018'
    password_confirmation 'B@rong2018'
    confirmed_at { Time.current }
  end
end
