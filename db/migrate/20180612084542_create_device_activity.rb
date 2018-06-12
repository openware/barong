class CreateDeviceActivity < ActiveRecord::Migration[5.1]
  def change
    create_table :devise_activity do |t|
      t.references :account, foreign_key: true, index: true, null: false
      t.string :device_uid, null: false, index: true
      t.string :user_ip, null: false
      t.string :user_os, null: false
      t.string :user_agent, null: false
      t.string :country, null: false
      t.string :status, null: false, index: true

      t.timestamps
    end
  end
end
