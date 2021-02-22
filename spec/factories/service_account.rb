# frozen_string_literal: true

FactoryBot.define do
  factory :service_account do
    user { FactoryBot.create(:user) }
    email { Faker::Internet.email }
    uid { Faker::Internet.email }

    trait :without_user do
      user { nil }
    end
  end
end
