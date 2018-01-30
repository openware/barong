class AddDeviseTwoFactorToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :encrypted_otp_secret, :string
    add_column :accounts, :encrypted_otp_secret_iv, :string
    add_column :accounts, :encrypted_otp_secret_salt, :string
    add_column :accounts, :consumed_timestep, :integer
    add_column :accounts, :otp_required_for_login, :boolean
  end
end
