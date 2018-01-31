require 'rotp'

class AddSeedToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :seed, :string, default: ""
  end
  def feed
    Account.all.each do |a|
      a.update_attributes(seed: ROTP::Base32.random_base32)
    end
  end
end
