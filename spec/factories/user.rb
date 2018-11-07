# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'Tecohvi0' }
    password_confirmation { 'Tecohvi0' }
    state { 'active' }

    trait :with_profile do
      after(:create) do |user, _|
        create(:profile, user: user)
      end
    end
  end
end
