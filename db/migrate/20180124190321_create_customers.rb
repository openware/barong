class CreateCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :customers do |t|
      t.string :first_name
      t.string :last_name
      t.date :dob
      t.string :address
      t.string :postcode
      t.string :city
      t.string :country

      t.timestamps
    end
  end
end
