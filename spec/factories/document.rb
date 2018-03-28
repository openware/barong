# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    profile

    doc_type 'passport'
    doc_number { Faker::Code.asin }
    doc_expire { Faker::Business.credit_card_expiry_date }

    before(:create) do |doc|
      doc.upload.download!(Faker::Avatar.image)
    end
  end
end
