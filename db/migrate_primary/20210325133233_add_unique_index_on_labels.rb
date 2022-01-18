class AddUniqueIndexOnLabels < ActiveRecord::Migration[5.2]
  def change
    remove_index :labels, [:user_id, :key, :scope]

    # Delete duplicated values
    ids = ActiveRecord::Base.connection.execute("SELECT MAX(ID) from labels l GROUP BY l.user_id, l.scope, l.key")

    Label.where.not(id: ids.to_a.flatten).find_each do |label|
      label.delete
    end

    add_index :labels, [:user_id, :key, :scope], unique: true
  end
end
