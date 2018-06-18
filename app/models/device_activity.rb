# frozen_string_literal: true

#
# Class DeviceActivity
#
class DeviceActivity < ApplicationRecord
  self.table_name = :device_activity

  validates :account_id, :action, :status, presence: true
  belongs_to :account

  acts_as_eventable prefix: 'device_activity', on: %i[create]

  def as_json_for_event_api
    {
      uid: account.uid,
      user_ip: user_ip,
      user_os: user_os,
      country: country,
      action: action,
      status: status,
      created_at: format_iso8601_time(created_at),
    }
  end
end

# == Schema Information
# Schema version: 20180612084542
#
# Table name: device_activity
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  device_uid :string(255)
#  user_ip    :string(255)      not null
#  user_os    :string(255)      not null
#  user_agent :string(255)      not null
#  country    :string(255)      not null
#  action     :string(255)      not null
#  status     :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_device_activity_on_account_id  (account_id)
#  index_device_activity_on_action      (action)
#  index_device_activity_on_device_uid  (device_uid)
#  index_device_activity_on_status      (status)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
