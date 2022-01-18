class CreateDataStorages < ActiveRecord::Migration[5.2]
  def change
    create_table :data_storages do |t|
      t.bigint :user_id, null: false, unsigned: true
      t.string :title, limit: 64, null: false
      t.text :data, limit: 5120, null: false

      t.timestamps
      t.index [:user_id, :title], unique: true
    end
  end
end
