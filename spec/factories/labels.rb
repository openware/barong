# frozen_string_literal: true

FactoryBot.define do
  factory :label do
    key { ::Faker::Internet.slug(nil, '-') }
    value { ::Faker::Internet.slug(nil, '-') }
    scope { 'public' }
    account { create(:account) }
  end
end
