class AddUniqueIndexToLabels < ActiveRecord::Migration[5.1]
  def change
    remove_index :labels, [:key, :value, :account_id]
    add_index :labels, [:key, :scope, :account_id], unique: true
  end
end
