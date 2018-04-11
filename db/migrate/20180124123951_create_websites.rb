# frozen_string_literal: true

class CreateWebsites < ActiveRecord::Migration[5.1]
  def change
    create_table :websites do |t|
      t.string :domain
      t.string :title
      t.string :logo
      t.string :stylesheet
      t.text :header
      t.text :footer
      t.string :redirect_url
      t.string :state

      t.timestamps
    end
    add_index :websites, :domain, unique: true
  end
end
