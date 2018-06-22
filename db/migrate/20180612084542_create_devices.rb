class CreateDevices < ActiveRecord::Migration[5.1]
  def change
    create_table :devices do |t|
      t.string :uuid
      t.string :action, null: false, index: true
      t.text :result, null: false
      t.string :ip
      t.string :os
      t.string :user_agent
      t.string :browser
      t.string :country
      t.string :otp
      t.datetime :expire_at
      t.references :account, foreign_key: true, index: true, null: false

      t.timestamps
    end
  end
end
