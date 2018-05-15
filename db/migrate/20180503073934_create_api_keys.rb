class CreateApiKeys < ActiveRecord::Migration[5.1]
  def change
    create_table :api_keys, id: false do |t|
      t.string :uid, limit: 36, primary_key: true, null: false
      t.text :public_key, null: false
      t.string :scopes
      t.integer :expires_in, null: false
      t.string :state, null: false, default: 'active'
      t.references :account, foreign_key: true, index: true, null: false

      t.timestamps
    end
  end
end
