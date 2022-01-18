class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities do |t|
      t.references :user,       null: false
      t.string     :user_ip,    null: false
      t.string     :user_agent, null: false
      t.string     :topic,      null: false
      t.string     :action,     null: false
      t.string     :result,     null: false
      t.text       :data,       null: true

      t.timestamp  :created_at # avoid updated_at as records not supposed to be updated
    end
  end
end
