class AddNicknameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :nickname, :string, after: :email
    add_index :users, :nickname, unique: true
  end
end
