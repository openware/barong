# frozen_string_literal: true

FactoryBot.define do
  factory :doorkeeper_token, class: Doorkeeper::AccessToken do
    application_id { FactoryBot.create(:doorkeeper_application).id }
    resource_owner_id { FactoryBot.create(:account).id }
    scopes :peatio
  end
end
