class ChangeLevelsStructure < ActiveRecord::Migration[5.2]
  def change
    remove_column :levels, :value
    rename_column :levels, :key, :requirements
  end
end
