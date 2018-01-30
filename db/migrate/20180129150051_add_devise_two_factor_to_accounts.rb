class AddDeviseTwoFactorToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :otp_required_for_login, :boolean
    add_column :accounts, :otp_secret, :string
  end
end
