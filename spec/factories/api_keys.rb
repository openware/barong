# frozen_string_literal: true

# == Schema Information
#
# Table name: apikeys
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           unsigned, not null
#  kid        :string(255)      not null
#  algorithm  :string(255)      not null
#  scope      :string(255)
#  state      :string(255)      default("active"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


FactoryBot.define do
  factory :api_key, class: 'APIKey' do
    user
    kid { Faker::Crypto.sha256 }
    scope { %w[trade] }
    algorithm { 'HS256' }
  end
end
