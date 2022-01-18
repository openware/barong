class ExtendUniquePermissionKey < ActiveRecord::Migration[5.2]
  def change
    remove_index :permissions, name: :permission_uniqueness
    add_index :permissions, [:role, :action, :verb, :path, :domain], unique: true, name: :permission_uniqueness
  end
end
