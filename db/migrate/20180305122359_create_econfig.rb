class CreateEconfig < ActiveRecord::Migration[5.1]
  def change
    create_table :config_settings do |t|
      t.string :key, null: false
      t.text :value
    end
    add_index :config_settings, :key, unique: true
  end
end
