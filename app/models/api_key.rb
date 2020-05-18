# frozen_string_literal: true

class APIKey < ApplicationRecord
  self.table_name = :apikeys

  ALGORITHMS = ['HS256'].freeze

  serialize :scope, Array

  JWT_OPTIONS = {
    verify_expiration: true,
    verify_iat: true,
    verify_jti: true,
    sub: 'api_key_jwt',
    verify_sub: true,
    iss: 'external',
    verify_iss: true,
    algorithm: 'RS256'
  }.freeze

  validates :user_id, :kid, presence: true
  validates :algorithm, inclusion: { in: ALGORITHMS }

  belongs_to :user
  scope :active, -> { where(state: 'active') }

  def hmac?
    self.algorithm.include?('HS')
  end

  def active?
    self.state == 'active'
  end
end

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
