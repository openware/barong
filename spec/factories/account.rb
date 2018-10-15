# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    sequence(:email) { |n| "user#{n}@gmail.com" }
    password { 'B@rong2018' }
    password_confirmation { 'B@rong2018' }
    confirmed_at { Time.current }
    state { 'active' }

    trait :with_profile do
      after(:create) do |account, _|
        create(:profile, account: account)
      end
    end
  end
end
