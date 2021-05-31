# frozen_string_literal: true

FactoryBot.define do
  factory :membership do
    id {}
    user_id {}
    organization_id {}
    role { 'member' }
  end
end
