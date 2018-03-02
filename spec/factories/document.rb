# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    uid "ID#{SecureRandom.hex(5).upcase}"
    upload { Faker::File.extension }
    doc_type 'Passport'
    doc_number 'AB12345'
    doc_expire { Faker::Date.forward(23) }
  end
end
