# frozen_string_literal: true

FactoryBot.define do
  factory :doorkeeper_token, class: Doorkeeper::AccessToken do
    association :application, factory: :doorkeeper_application
    resource_owner_id { create(:account).id }
    scopes { :peatio }
  end
end
