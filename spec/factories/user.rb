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

    trait :with_document do
      after(:create) do |user, _|
        create(:document, user: user)
      end
    end

    trait :with_phone do
      after(:create) do |user, _|
        create(:phone, user: user)
      end
    end

    trait :with_document_phone_profile do
      after(:create) do |user, _|
        create(:phone, user: user)
        create(:profile, user: user)
        create(:document, user: user)
      end
    end
  end
end
