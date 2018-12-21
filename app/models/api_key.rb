# frozen_string_literal: true

class APIKey < ApplicationRecord
  self.table_name = :apikeys

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

  belongs_to :user
  scope :active, -> { where(state: 'active') }

  def hmac?
    self.algorithm.include?('HS')
  end

  def active?
    self.state == 'active'
  end
end