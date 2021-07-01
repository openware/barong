# frozen_string_literal: true

FactoryBot.define do
  factory :attachment do
    user { FactoryBot.create(:user) }

    after(:build) do |attachment|
      attachment.upload.download!(Faker::Company.logo)
    end
  end
end
