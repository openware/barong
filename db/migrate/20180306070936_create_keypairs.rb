# frozen_string_literal: true

class CreateKeypairs < ActiveRecord::Migration[5.1]
  def change
    create_table :keypairs do |t|
      t.string  :label
      t.string  :token

      t.integer :rake_limit

      t.timestamps
    end
  end
end
