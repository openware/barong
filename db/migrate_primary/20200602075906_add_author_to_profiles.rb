class AddAuthorToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :author, :string, null: true, after: :user_id
  end
end
