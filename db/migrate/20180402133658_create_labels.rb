# frozen_string_literal: true

class CreateLabels < ActiveRecord::Migration[5.1]
  def change
    create_table :labels do |t|
      t.references :account
      t.string :key, null: false
      t.string :value, null: false
      t.string :scope, null: false, default: 'public'

      t.timestamps
    end
    add_index :labels, %i[key value account_id], unique: true
    add_foreign_key :labels, :accounts, on_delete: :cascade
  end
end
