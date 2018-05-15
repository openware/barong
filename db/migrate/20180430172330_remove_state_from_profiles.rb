class RemoveStateFromProfiles < ActiveRecord::Migration[5.1]
  def change
    remove_column :profiles, :state
  end
end
