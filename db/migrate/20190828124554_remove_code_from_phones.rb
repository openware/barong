class RemoveCodeFromPhones < ActiveRecord::Migration[5.2]
  def change
    remove_column :phones, :code, :string if column_exists?(:phones, :code)
  end
end
