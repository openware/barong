class AddRetriesToPhones < ActiveRecord::Migration[5.2]
  def change
    add_column :phones, :retries_send, :integer, default: 0, null: false
    add_column :phones, :retries_verify, :integer, default: 0, null: false
  end
end
