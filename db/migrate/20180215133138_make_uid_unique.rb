class MakeUidUnique < ActiveRecord::Migration[5.1]
  def change
    remove_index :accounts, :uid if index_exists?(:accounts, :uid)
    add_index :accounts, :uid, unique: true
  end
end
