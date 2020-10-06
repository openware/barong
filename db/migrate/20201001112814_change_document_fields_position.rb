class ChangeDocumentFieldsPosition < ActiveRecord::Migration[5.2]
  def up
    change_column :documents, :doc_issue, :date, after: :doc_number_index
    change_column :documents, :doc_category, :string, after: :doc_issue
  end

  def down
    change_column :documents, :doc_issue, :date, after: :updated_at
    change_column :documents, :doc_category, :string, after: :doc_issue
  end
end
