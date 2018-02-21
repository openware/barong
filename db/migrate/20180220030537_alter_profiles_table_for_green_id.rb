class AlterProfilesTableForGreenId < ActiveRecord::Migration[5.1]
  def change    
    add_column :profiles, :middle_name, :string, after: :last_name
    add_column :profiles, :flat_number, :string, after: :dob
    add_column :profiles, :street_number, :string, after: :flat_number
    rename_column :profiles, :address, :street_name
    add_column :profiles, :street_type, :string, after: :street_name
    rename_column :profiles, :city, :suburb
    add_column :profiles, :address_state, :string, after: :suburb
    add_column :profiles, :green_id_status, :string, after: :country
  end
end
