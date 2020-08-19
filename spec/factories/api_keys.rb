# frozen_string_literal: true

# == Schema Information
#
# Table name: apikeys
#
#  id                      :bigint           not null, primary key
#  key_holder_account_id   :bigint           unsigned, not null
#  key_holder_account_type :string(255)      default("User"), not null
#  kid                     :string(255)      not null
#  algorithm               :string(255)      not null
#  scope                   :string(255)
#  secret_encrypted        :string(1024)
#  state                   :string(255)      default("active"), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#


FactoryBot.define do
  factory :api_key, class: 'APIKey' do
    kid { Faker::Crypto.sha256 }
    secret { SecureRandom.hex(16) }
    scope { %w[trade] }
    algorithm { 'HS256' }
  end
end
