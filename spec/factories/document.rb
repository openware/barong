# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    account

    doc_type { 'Passport' }
    doc_number { Faker::Code.asin }
    doc_expire { Faker::Business.credit_card_expiry_date }

    after(:build) do |doc|
      doc.upload.download!(Faker::Company.logo)
    end
  end
end
