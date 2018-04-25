# frozen_string_literal: true

class CreateLevelMappings < ActiveRecord::Migration[5.1]
  def change
    create_table :level_mappings do |t|
      t.integer :account_level, null: false
      t.string :label_key, null: false
      t.string :label_value, null: false
      t.index %i[label_key label_value], unique: true
      t.timestamps
    end
  end
end
