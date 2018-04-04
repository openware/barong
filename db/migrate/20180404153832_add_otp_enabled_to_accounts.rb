# frozen_string_literal: true

class AddOtpEnabledToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :otp_enabled, :boolean, default: false, after: :level
  end
end
