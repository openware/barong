# frozen_string_literal: true

FactoryBot.define do
  factory :device do
    action 'device'
    result 'success'
    account
  end
end
