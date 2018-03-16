# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
   uid "ID#{SecureRandom.hex(5).upcase}"
   first_name { Faker::Name.first_name }
   last_name { Faker::Name.last_name }
   dob { Faker::Date.birthday(21, 65) }
   address { Faker::Address.street_address }
   postcode { Faker::Address.postcode }
   city { Faker::Address.city }
   country { Faker::Address.country }
  end
end
