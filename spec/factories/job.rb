# frozen_string_literal: true

FactoryBot.define do
  factory :job do
    description { Faker::Lorem.sentence }
    type { "maintenance" }
    state { "pending" }
    start_at { Time.now + 1 }

    trait :with_maintenance_restriction do
      after(:create) do |job, _|
        maintenance = create(:restriction, 
                              category: :maintenance, scope: :all, value: :all, state: :disabled)
        create(:jobbing, job: job, reference: maintenance)
      end
    end
  end
end
