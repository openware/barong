# frozen_string_literal: true

FactoryBot.define do
  factory :website do
    domain { Faker::Internet.domain_name }
    title { Faker::RickAndMorty.character }
    logo { Faker::Internet.url }
    stylesheet { Faker::Internet.url }
    header { Faker::RickAndMorty.quote }
    footer { Faker::RickAndMorty.quote }
    redirect_url { Faker::Internet.url }
  end
end
