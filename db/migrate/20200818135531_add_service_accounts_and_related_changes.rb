class AddServiceAccountsAndRelatedChanges < ActiveRecord::Migration[5.2]
  class APIKey < ActiveRecord::Base
    self.table_name = :apikeys
  end

  def change
    create_table :service_accounts do |t|
      t.string    :uid,                 null: false
      t.bigint    :provider_id,         null: false, unsigned: true
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
    add_index :apikeys, [:key_holder_account_type, :key_holder_account_id], name: :idx_apikey_on_account
  end
end
