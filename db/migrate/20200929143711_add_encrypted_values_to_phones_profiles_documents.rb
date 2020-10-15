class AddEncryptedValuesToPhonesProfilesDocuments < ActiveRecord::Migration[5.2]
  def up
    # Phones Table
    add_column :phones, :number_encrypted, :string, null: false, after: :code
    add_column :phones, :number_index, :bigint, null: false, after: :number_encrypted
    add_index :phones, [:number_index]

    # Encrypt number
    Phone.find_each(batch_size: 100) do |phone|
      phone.update_attribute(:number, phone.read_attribute(:number))
    end

    remove_column :phones, :number, :string

    # Profiles Table
    add_column :profiles, :first_name_encrypted, :string, limit: 1024, after: :applicant_id
    add_column :profiles, :last_name_encrypted, :string, limit: 1024, after: :first_name_encrypted
    add_column :profiles, :dob_encrypted, :string, after: :last_name_encrypted
    add_column :profiles, :address_encrypted, :string, limit: 1024, after: :dob_encrypted

    # Encrypt first_name, last_name, dob, address
    Profile.find_each(batch_size: 100) do |profile|
      attrs = {
        first_name: profile.read_attribute(:first_name),
        last_name:  profile.read_attribute(:last_name),
        dob:        profile.read_attribute(:dob),
        address:    profile.read_attribute(:address)
      }.compact

      profile.update_attributes(attrs) if attrs.present?
    end

    remove_column :profiles, :first_name, :string
    remove_column :profiles, :last_name, :string
    remove_column :profiles, :dob, :date
    remove_column :profiles, :address, :string

    # Documents table
    add_column :documents, :doc_number_encrypted, :string, after: :doc_expire
    add_column :documents, :doc_number_index, :bigint, after: :doc_number_encrypted
    add_index :documents, [:doc_number_index]

    # Encrypt doc_number
    Document.where.not(doc_number: nil).find_each(batch_size: 100) do |document|
      document.update_attribute(:doc_number, document.read_attribute(:doc_number))
    end

    remove_column :documents, :doc_number, :string
  end

  def down
    # Phones Table
    add_column :phones, :number, :string, null: false, after: :country

    # Decrypt number
    Phone.find_each(batch_size: 100) do |phone|
      phone.update_column(:number, phone.number)
    end

    remove_index :phones, column: :number_index
    remove_column :phones, :number_encrypted, :string
    remove_column :phones, :number_index, :bigint

    # Profiles Table
    add_column :profiles, :first_name, :string, after: :applicant_id
    add_column :profiles, :last_name, :string, after: :first_name
    add_column :profiles, :dob, :date, after: :last_name
    add_column :profiles, :address, :string, after: :dob

    # Decrypt first_name, last_name, dob, address
    Profile.find_each(batch_size: 100) do |profile|
      attrs = {
        first_name: profile.first_name,
        last_name:  profile.last_name,
        dob:        profile.dob,
        address:    profile.address
      }.compact

      profile.update_columns(attrs) if attrs.present?
    end

    remove_column :profiles, :first_name_encrypted, :string
    remove_column :profiles, :last_name_encrypted, :string
    remove_column :profiles, :dob_encrypted, :string
    remove_column :profiles, :address_encrypted, :string

    # Documents table
    add_column :documents, :doc_number, :string, after: :doc_type

    # Decrypt doc_number
    Document.where.not(doc_number_encrypted: nil).find_each(batch_size: 100) do |document|
      document.update_column(:doc_number, document.doc_number)
    end

    remove_index :documents, column: :doc_number_index
    remove_column :documents, :doc_number_encrypted, :string
    remove_column :documents, :doc_number_index, :bigint
  end
end
