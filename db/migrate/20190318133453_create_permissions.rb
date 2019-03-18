class CreatePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :permissions do |t|
      t.string :role,      null: false, default: 'member'
      t.string :req_type,  null: false
      t.string :path,      null: false

      t.timestamps
    end
  end
end
