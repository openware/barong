class AddCodeAndTypeInRestrictionsTable < ActiveRecord::Migration[5.2]
  def change
    add_column :restrictions, :code, :integer, null: true, after: :value
    add_column :restrictions, :category, :string, null: false, after: :id
  end
end
