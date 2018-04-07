# frozen_string_literal: true

class CreatePhones < ActiveRecord::Migration[5.1]
  def change
    create_table :phones do |t|
      t.string :country
      t.string :number,         null: false
      t.datetime :validated_at
      t.integer :account_id,    null: false, unsigned: true, index: true

      t.timestamps
    end

    add_index :phones, :number, unique: true
  end
end
