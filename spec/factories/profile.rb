# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    account

    first_name { Faker::Name.first_name        }
    last_name  { Faker::Name.last_name         }
    dob        { Faker::Time.birthday          }
    address    { Faker::Address.street_address }
    postcode   { Faker::Address.postcode       }
    city       { Faker::Address.country        }
    country    { Faker::Address.street_address }
  end
end
