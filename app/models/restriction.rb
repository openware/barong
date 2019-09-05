# frozen_string_literal: true

class Restriction < ApplicationRecord
  SCOPES = %w[continent country ip ip_subnet]
  STATES = %w[enabled disabled]
  SUBNET_REGEX = /\A([0-9]{1,3}\.){3}[0-9]{1,3}\/([0-9]|[1-2][0-9]|3[0-2])\z/

  validates :scope, :value, presence: true
  validates :scope, inclusion: { in: SCOPES }
  validates :state, inclusion: { in: STATES }

  validates :value, if: -> { scope == 'ip' },
            format: { :with => Resolv::IPv4::Regex },
            uniqueness: true

  validates :value, if: -> { scope == 'ip_subnet' },
            format: { :with => SUBNET_REGEX },
            uniqueness: true
end

# == Schema Information
#
# Table name: restrictions
#
#  id         :bigint           not null, primary key
#  scope      :string(64)       not null
#  value      :string(64)       not null
#  state      :string(16)       default("enabled"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
