class CreateLevels < ActiveRecord::Migration[5.1]
  def change
    create_table :levels do |t|
      t.string :key
      t.string :value
      t.string :description

      t.timestamps
    end
  end
end
