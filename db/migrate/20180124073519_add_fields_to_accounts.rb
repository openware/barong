class AddFieldsToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :real_name, :string
    add_column :accounts, :birth_date, :datetime
    add_column :accounts, :address, :string
    add_column :accounts, :city, :string
    add_column :accounts, :country, :string
    add_column :accounts, :zipcode, :string
    add_column :accounts, :document_type, :string
    add_column :accounts, :document_number, :string
    add_column :accounts, :doc_photo, :string
    add_column :accounts, :residence_proof, :string
    add_column :accounts, :residence_photo, :string
    add_column :accounts, :verified, :boolean, default: false
    add_column :accounts, :status, :boolean, default: false
  end
  # add_presence_constraint :accounts, :document_type, if: "status = 'true'"
  # add_presence_constraint :accounts, :real_name, if: "status = 'true'"
  # add_presence_constraint :accounts, :document_number, if: "status = 'true'"
  # add_presence_constraint :accounts, :residence_proof, if: "status = 'true'"
end
