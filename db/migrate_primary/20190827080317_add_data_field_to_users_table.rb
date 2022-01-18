class AddDataFieldToUsersTable < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :data, :text, null: true, after: :role
  end
end
