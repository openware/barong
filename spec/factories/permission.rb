# frozen_string_literal: true

FactoryBot.define do
  factory :permission do
    role { %w[member trader broker admin accountant support technical compliance superadmin] }
    path { 'api/v2' }
    action { 'ACCEPT' }
    verb { %w[get post put delete head patch all] }
  end
end
