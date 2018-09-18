# frozen_string_literal: true

FactoryBot.define do
  factory :api_key, class: 'APIKey' do
    account
    public_key { Faker::Crypto.sha256 }
    scopes { %w[trade] }
  end
end
