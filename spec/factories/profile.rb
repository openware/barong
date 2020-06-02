# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    user { FactoryBot.create(:user) }
    author { }
    first_name { Faker::Name.first_name  }
    last_name { Faker::Name.last_name }
    dob { Faker::Date.birthday }
    address { Faker::Address.state }
    city { Faker::Address.city }
    country { Faker::Address.country_code_long }
    postcode { Faker::Address.postcode }
  end
end
