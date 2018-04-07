# frozen_string_literal: true

class CreateProfiles < ActiveRecord::Migration[5.1]
  def change
    create_table :profiles do |t|
      t.references :account, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.date :dob
      t.string :address
      t.string :postcode
      t.string :city
      t.string :country
      t.string :state, null: false, default: 'pending'

      t.timestamps
    end
  end
end
