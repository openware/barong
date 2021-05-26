# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    id {}
    oid {}
    parent_id {}
    name {}
    status { 'active' }
  end
end
