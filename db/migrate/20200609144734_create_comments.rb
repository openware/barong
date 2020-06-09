class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.bigint :user_id, null: false, unsigned: true
      t.string :author_uid, limit: 16, null: false
      t.string :title, limit: 64, null: false
      t.text   :data, limit: 5120, null: false

      t.timestamps
      t.index :user_id
    end
  end
end
