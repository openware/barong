class AddPlatformIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :platform_id, :integer, after: :referral_id

    remove_index :users, column: :email
  end
end
