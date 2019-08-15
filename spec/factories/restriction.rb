# frozen_string_literal: true

FactoryBot.define do
  factory :restriction do
    scope { 'ip_subnet' }
    value { '0.0.0.0/0' }
  end
end
