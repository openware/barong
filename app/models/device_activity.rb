# frozen_string_literal: true

#
# Class DeviceActivity
#
class DeviceActivity < ApplicationRecord
  self.table_name = :device_activity

  validates :account_id, :device_uid, :user_ip, :user_os,
            :user_agent, :country, :status, presence: true
end
\
