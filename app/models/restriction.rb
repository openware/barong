# frozen_string_literal: true

class Restriction < ApplicationRecord
  # please, note that order in CATEGORIES contstant defines the ierarchy
  CATEGORIES = %w[whitelist maintenance blacklist blocklogin].freeze
  SCOPES = %w[continent country ip ip_subnet all]
  # 423 Locked 403 Forbidden 401 Forbidden
  DEFAULT_CODES = { continent: 423, country: 423, ip_subnet: 403, ip: 401, all: 401 }.stringify_keys.freeze
  STATES = %w[enabled disabled]
  SUBNET_REGEX = /\A([0-9]{1,3}\.){3}[0-9]{1,3}\/([0-9]|[1-2][0-9]|3[0-2])\z/

  validates :scope, :value, :category, presence: true
  validates :scope, inclusion: { in: SCOPES }
  validates :state, inclusion: { in: STATES }
  validates :category, inclusion: { in: CATEGORIES }

  validates_uniqueness_of :value, scope: %i[scope category]

  validates :value, if: -> { scope == 'ip' },
            format: { :with => Resolv::IPv4::Regex }

  validates :value, if: -> { scope == 'ip_subnet' },
            format: { :with => SUBNET_REGEX }

  before_validation :assign_code

  after_save :destroy_sessions

  private

  def destroy_sessions
    if category == 'blocklogin' && state == 'enabled'
      Rails.cache.delete_matched('*_session_id*') if state_previously_changed? || created_at_previously_changed?
    end
  end

  def assign_code
    return unless code.blank? || category == 'whitelist'

    self.code = category == 'maintenance' ? 471 : DEFAULT_CODES[scope]
  end
end

# == Schema Information
#
# Table name: restrictions
#
#  id         :bigint           not null, primary key
#  category   :string(255)      not null
#  scope      :string(64)       not null
#  value      :string(64)       not null
#  code       :integer
#  state      :string(16)       default("enabled"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
