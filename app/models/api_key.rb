# frozen_string_literal: true

class APIKey < ApplicationRecord
  self.table_name = :apikeys

  include Vault::EncryptedModel

  ALGORITHMS = ['HS256'].freeze
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


  vault_lazy_decrypt!

  vault_attribute :secret

  serialize :scope, Array

  belongs_to :key_holder_account, polymorphic: true

  validates :kid, :secret, presence: true
  validates :kid, uniqueness: true
  validates :algorithm, inclusion: { in: ALGORITHMS }

  before_validation :assign_kid, if: :hmac?
  before_validation :validate_key_holder_state, on: :create
  before_validation :validate_api_key_state, on: :update

  scope :active, -> { where(state: 'active') }

  def assign_kid
    return unless kid.blank?

    loop do
      self.kid = random_kid
      break unless APIKey.where(kid: kid).any?
    end
  end

  def random_kid
    SecureRandom.hex(8)
  end

  def hmac?
    self.algorithm.include?('HS')
  end

  def active?
    self.state == 'active'
  end

  private

  def validate_key_holder_state
    errors.add(:key_holder_account, :invalid, message: 'non active state for key holder account') unless key_holder_account.active?
  end

  def validate_api_key_state
    errors.add(:state, :invalid, message: 'cant activate api key with disabled key holder account') if active? && !key_holder_account.active?
  end
end

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
# Indexes
#
#  idx_apikey_on_account  (key_holder_account_type,key_holder_account_id)
#  index_apikeys_on_kid   (kid) UNIQUE
#
