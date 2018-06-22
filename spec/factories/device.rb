# frozen_string_literal: true

FactoryBot.define do
  factory :device do
    uid { SecureRandom.hex }
    account
    last_sign_in { Time.current }
  end
end
