class AddDescriptionToLabels < ActiveRecord::Migration[5.2]
  def change
    add_column :labels, :description, :string, null: true, after: :scope
  end
end
