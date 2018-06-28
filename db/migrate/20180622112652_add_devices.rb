class AddDevices < ActiveRecord::Migration[5.1]
  def change
    create_table :devices, id: false do |t|
      t.string :uid, limit: 36, primary_key: true, null: false
      t.references :account, foreign_key: true, index: true, null: false
      t.datetime :last_sign_in
      t.datetime :check_otp_time

      t.timestamps
    end
  end
end
