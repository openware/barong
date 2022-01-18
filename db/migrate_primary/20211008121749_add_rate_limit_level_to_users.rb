class AddRateLimitLevelToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :rate_limit_level, :integer, null: false, default: 1
  end
end
