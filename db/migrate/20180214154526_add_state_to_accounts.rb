class AddStateToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :state, :string, after: :level, null:false, default:'active'
  end
end
