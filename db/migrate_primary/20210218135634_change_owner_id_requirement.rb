class ChangeOwnerIdRequirement < ActiveRecord::Migration[5.2]
  def up
    change_column :service_accounts, :owner_id, :bigint, null: true, unsigned: true
  end

  def down
    change_column :service_accounts, :owner_id, :bigint, null: false, unsigned: true
  end
end
