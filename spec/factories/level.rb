# frozen_string_literal: true

FactoryBot.define do
  factory :level do
    key { Faker::Hacker.noun }
    value { Faker::Hacker.adjective }
    description { Faker::Hacker.say_something_smart }
  end
end
