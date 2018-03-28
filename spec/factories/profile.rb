# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    account { FactoryBot.create(:account) }
    first_name { Faker::Superhero.name }
    last_name { Faker::Superhero.name }
    dob { Faker::Date.birthday }
    address { Faker::Address.street_address }
    city { Faker::RickAndMorty.location }
    country { Faker::Simpsons.location }
    state { 'validated' }

    transient do
      documents_count 1
    end

    after(:create) do |profile, evaluator|
      create_list(:document, evaluator.documents_count, profile: profile)
    end
  end
end
