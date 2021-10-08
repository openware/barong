class AddApiKeysLimitToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :api_keys_limit, :integer, null: false, default: 1
  end
end
