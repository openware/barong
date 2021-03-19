class CreatePlatforms < ActiveRecord::Migration[5.2]
  def change
    create_table :platforms do |t|
      t.string :platform_id, null: false
      t.string :hostname, null: false

      t.timestamps
    end

  end
end
