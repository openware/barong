# frozen_string_literal: true

FactoryBot.define do
  factory :api_key, class: 'APIKey' do
    user
    kid { Faker::Crypto.sha256 }
    scope { { 'trade': 'read' } }
    algorithm { 'HS256' }
  end
end
