class CreateAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :attachments do |t|
      t.bigint :user_id, unsigned: true
      t.string :upload, null: false
      t.timestamps
    end
  end
end
