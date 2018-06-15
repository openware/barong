class CreateDeviceActivity < ActiveRecord::Migration[5.1]
  def change
    create_table :device_activity do |t|
      t.references :account, foreign_key: true, index: true, null: false
      t.string :device_uid
      t.string :user_ip
      t.string :user_os
      t.string :user_agent
      t.string :user_browser
      t.string :country
      t.string :action, null: false, index: true
      t.string :status, null: false, index: true

      t.timestamps
    end
  end
end
