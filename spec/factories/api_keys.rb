# frozen_string_literal: true

FactoryBot.define do
  factory :api_key, class: 'APIKey' do
    kid { Faker::Crypto.sha256 }
    secret { SecureRandom.hex(16) }
    scope { %w[trade] }
    algorithm { 'HS256' }

    trait :with_service_account do
      key_holder_account { create(:service_account) }
    end

    trait :with_user do
      key_holder_account { create(:user) }
    end
  end
end
