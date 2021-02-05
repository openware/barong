# frozen_string_literal: true

FactoryBot.define do
  factory :jobbing do
    job { create(:job) }
    reference { create(:restriction) }
  end
end
