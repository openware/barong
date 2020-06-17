class AddDocCategoryToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :doc_category, :string
  end
end
