# frozen_string_literal: true

FactoryBot.define do
  factory :phone do
    number { '12345678911' }
    account
  end
end
