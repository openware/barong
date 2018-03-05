# frozen_string_literal: true

class CreateKeys < ActiveRecord::Migration[5.1]
  def change
    create_table :keys do |t|
      t.string  :label
      t.string  :token

      t.integer :rake_limit

      t.timestamps
    end
  end
end
