class CreateRestrictions < ActiveRecord::Migration[5.2]
  def change
    create_table :restrictions do |t|

      t.string :scope, limit: 64, null: false
      t.string :value, limit: 64, null: false
      t.string :state, limit: 16, default: 'enabled', null: false

      t.timestamps
    end
  end
end
