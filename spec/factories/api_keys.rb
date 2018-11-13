# frozen_string_literal: true

FactoryBot.define do
  factory :api_key, class: 'APIKey' do
    user
    kid { Faker::Crypto.sha256 }
    scope { %w[trade] }
    algorithm { 'HS256' }
  end
end
