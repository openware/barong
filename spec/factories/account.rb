# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    email    { Faker::Internet.email }
    password { Faker::Internet.password(8, 16, true, true) }

    trait :confirmed do
      after(:create, &:confirm)
    end

    trait :with_profile do
      after(:create) do |account|
        create :profile, account: account
      end
    end

    factory :admin do
      confirmed
      role 'admin'
    end
  end
end
