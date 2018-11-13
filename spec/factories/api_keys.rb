# frozen_string_literal: true

FactoryBot.define do
  factory :apikey, class: 'APIKey' do
    user
    kid { Faker::Crypto.sha256 }
    scope { %w[trade] }
    algorithm { 'RS256' }
  end
end
