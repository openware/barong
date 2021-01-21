class AddNicknameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :nickname, :string, null: true
    add_index :users, :nickname, unique: true, where: 'nickname IS NOT NULL'
  end
end
