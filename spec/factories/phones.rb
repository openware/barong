# frozen_string_literal: true

FactoryBot.define do
  factory :phone do
    number { "12345678#{rand(10)}#{rand(10)}#{rand(10)}" }
    user
  end
end
