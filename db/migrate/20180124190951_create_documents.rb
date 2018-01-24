class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents do |t|
      t.integer :customer_id
      t.string :upload_id
      t.string :upload_filename
      t.string :upload_content_size
      t.string :upload_content_type
      t.string :doc_type
      t.string :doc_number
      t.date :doc_expire

      t.timestamps
    end
  end
end
