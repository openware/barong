# frozen_string_literal: true

FactoryBot.define do
  factory :label do
    key { ::Faker::Internet.slug(glue: '-') }
    value { ::Faker::Internet.slug(glue: '-') }
    scope { 'public' }
    user { create(:user) }
  end
end
