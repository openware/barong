# frozen_string_literal: true

#
# Class Device
#
class Device < ApplicationRecord
  acts_as_eventable prefix: 'device', on: %i[create update]

  belongs_to :account
  validates :uid, presence: true
  validates :account_id, presence: true

  before_validation :assign_uid

  def assign_uid
    return unless uid.blank?
    loop do
      self.uid = SecureRandom.hex
      break unless self.class.where(uid: uid).exists?
    end
  end

  def as_json_for_event_api
    {
      device_uid: uid,
      account_uid: account.uid,
      last_sign_in: format_iso8601_time(last_sign_in),
      created_at: format_iso8601_time(created_at),
      updated_at: format_iso8601_time(updated_at)
    }
  end
end

# == Schema Information
# Schema version: 20180622112652
#
# Table name: devices
#
#  uid            :string(36)       not null, primary key
#  account_id     :integer          not null
#  last_sign_in   :datetime
#  check_otp_time :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_devices_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
