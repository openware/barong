# frozen_string_literal: true

FactoryBot.define do
  factory :public_address do
    uid { UIDGenerator.generate('PA') }
    role { 'member' }
    address { Faker::Blockchain::Ethereum.address }
  end
end
