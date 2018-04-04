class AddOtpEnabledToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :otp_enabled, :boolean, default: false
  end
end
