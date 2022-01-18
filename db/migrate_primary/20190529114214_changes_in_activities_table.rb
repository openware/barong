class ChangesInActivitiesTable < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :target_uid, :string, after: :user_id
    add_column :activities, :category, :string, after: :target_uid
    add_column :permissions, :topic, :string, after: :path

    add_index :activities, :target_uid
    add_index :permissions, :topic
  end
end
