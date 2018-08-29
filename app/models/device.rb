# frozen_string_literal: true

#
# Class Device
#
class Device < ApplicationRecord
  acts_as_eventable prefix: 'device', on: %i[create update]

  serialize :result, JSON
  validates :account_id, :uuid, :action, :result, presence: true
  belongs_to :account
  before_validation :assign_uuid, if: -> (m) { m.uuid.blank? }
  before_create :set_expire_time
  before_create :set_otp

  def as_json_for_event_api
    {
      device_uuid: uuid,
      uid: account.uid,
      ip: ip,
      os: os,
      country: country,
      action: action,
      result: result,
      user_agent: user_agent,
      browser: browser,
      otp: otp,
      expire_at: expire_at,
      created_at: format_iso8601_time(created_at),
      updated_at: format_iso8601_time(updated_at)
    }
  end

private

  def set_expire_time
    return unless otp == 'provided' && result == 'success'
    self.expire_at = 30.days.from_now
  end

  def set_otp
    return unless %w[0 1].include?(otp)
    self.otp = if otp == '1'
                 'provided'
               else
                 account.otp_enabled ? 'enabled' : 'na'
               end
  end

  def assign_uuid
    loop do
      self.uuid = SecureRandom.hex
      break unless self.class.where(uuid: uuid).exists?
    end
  end
end

# == Schema Information
# Schema version: 20180612084542
#
# Table name: devices
#
#  id         :integer          not null, primary key
#  uuid       :string(255)
#  action     :string(255)      not null
#  result     :text(65535)      not null
#  ip         :string(255)
#  os         :string(255)
#  user_agent :string(255)
#  browser    :string(255)
#  country    :string(255)
#  otp        :string(255)
#  expire_at  :datetime
#  account_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_devices_on_account_id  (account_id)
#  index_devices_on_action      (action)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
