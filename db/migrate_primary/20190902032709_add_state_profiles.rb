class AddStateProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :state, :integer, unsigned: true, limit: 1, after: :country
  end
end
