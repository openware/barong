# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents do |t|
      t.references :profile, foreign_key: true
      t.string :upload
      t.string :doc_type
      t.string :doc_number
      t.date :doc_expire

      t.timestamps
    end
  end
end
