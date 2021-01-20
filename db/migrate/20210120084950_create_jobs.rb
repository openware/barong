class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.string :type, limit: 20, default: 'maintenance', null: false 
      t.text :reason, null: true
      t.string :state, limit: 20, default: 'pending', null: false
      t.datetime :start_at, null: true
      t.datetime :finish_at, null: true

      t.timestamps
    end

    add_reference :jobs, :reference, polymorphic: true, index: true, null: false
  end
end
