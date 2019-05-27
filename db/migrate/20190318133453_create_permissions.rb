class CreatePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :permissions do |t|

      t.string    :action,     null: false
      t.string    :role,       null: false
      t.string    :verb, null: false
      t.string    :path,       null: false

      t.timestamps
    end
  end
end
