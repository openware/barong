class AddPublicAddressesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :public_addresses do |t|
      t.string    :uid,   null: false
      t.string    :role,  null: false
      t.string    :public_address, null: false
      t.integer   :level, default: 1, null: false
      t.string    :state, default: "active", null: false

      t.timestamps
    end
  end
end
