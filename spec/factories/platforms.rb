FactoryBot.define do
  factory :platform do
    platform_id { Faker::Internet.uuid  }
    hostname { Faker::Internet.domain_name }
  end
end
