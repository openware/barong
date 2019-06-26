# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    user

    doc_type { 'Passport' }
    doc_number { Faker::Code.asin }
    doc_expire { Faker::Business.credit_card_expiry_date }

  end
end
