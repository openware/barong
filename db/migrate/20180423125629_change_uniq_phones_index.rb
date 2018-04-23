# frozen_string_literal: true

class ChangeUniqPhonesIndex < ActiveRecord::Migration[5.1]
  def up
    remove_index :phones, :number
    add_index :phones, :number
  end

  def down
    remove_index :phones, :number
    add_index :phones, :number, unique: true
  end
end
