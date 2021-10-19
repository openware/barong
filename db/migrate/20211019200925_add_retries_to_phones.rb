class AddRetriesToPhones < ActiveRecord::Migration[5.2]
  def change
    add_column :phones, :retries, :integer, default: 0, null: false
  end
end
