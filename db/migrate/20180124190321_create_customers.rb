class CreateCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :customers do |t|
      t.string      :first_name,  null: false
      t.string      :last_name,   null: false
      t.string      :address
      t.string      :postcode
      t.string      :city
      t.string      :country

      t.date        :dob

      t.references  :account,     null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
