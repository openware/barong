class AddIdentificatorToDocumentsTable < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :identificator, :string, after: :doc_expire
    add_column :documents, :doc_issue, :date, before: :doc_expire
    add_column :profiles, :applicant_id, :string, after: :user_id
  end
end
