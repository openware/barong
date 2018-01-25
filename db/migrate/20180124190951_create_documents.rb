class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents do |t|
      t.string      :upload_id
      t.string      :upload_filename
      t.string      :upload_content_size
      t.string      :upload_content_type
      t.string      :doc_type
      t.string      :doc_number

      t.date        :doc_expire

      t.references  :customer, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
