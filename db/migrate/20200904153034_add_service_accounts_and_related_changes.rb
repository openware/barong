class AddServiceAccountsAndRelatedChanges < ActiveRecord::Migration[5.2]
  class APIKey < ActiveRecord::Base
    self.table_name = :apikeys
  end

  def up
    create_table :service_accounts do |t|
      t.string    :uid,                 null: false
      t.bigint    :owner_id,            null: false, unsigned: true
      t.string    :email,               null: false
      t.string    :role,                default: "service_account", null: false
      t.integer   :level,               default: 0, null: false
      t.string    :state,               default: "pending", null: false

      t.timestamps
    end

    add_column :apikeys, :key_holder_account_id, :bigint, null: false, unsigned: true, after: :id
    add_column :apikeys, :key_holder_account_type, :string, null: false, default: "User", after: :key_holder_account_id

    APIKey.find_each do |api_key|
      api_key.key_holder_account_type = 'User'
      api_key.key_holder_account_id = api_key.user_id
      api_key.save!
    end

    remove_column :apikeys, :user_id
    add_index :apikeys, [:key_holder_account_type, :key_holder_account_id], name: :idx_apikey_on_account unless index_exists?(:service_accounts, [:key_holder_account_type, :key_holder_account_id])
  end

  def down
    add_column :apikeys, :user_id, :bigint, unsigned: true, null: false, after: :key_holder_account_id

    APIKey.find_each do |api_key|
      if api_key.key_holder_account_type == 'ServiceAccount'
        api_key.destroy!
        next
      end

      api_key.user_id = api_key.key_holder_account_id
      api_key.save!
    end

    remove_column :apikeys, :key_holder_account_id
    remove_column :apikeys, :key_holder_account_type

    remove_index :service_accounts, column: [:key_holder_account_type, :key_holder_account_id] if index_exists?(:service_accounts, [:key_holder_account_type, :key_holder_account_id])
    drop_table :service_accounts
  end
end
