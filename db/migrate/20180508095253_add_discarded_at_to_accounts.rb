class AddDiscardedAtToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :discarded_at, :datetime, after: :state
    add_index :accounts, :discarded_at
  end
end
