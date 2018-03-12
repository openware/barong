class AlterDocumentsTableForGreenId < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :doc_state, :string, after: :doc_number
    add_column :documents, :green_id_status, :string, after: :doc_state
    remove_column :documents, :doc_expire
    add_column :documents, :doc_file_name_2, :string, after: :upload
    rename_column :documents, :upload, :doc_file_name
  end
end
