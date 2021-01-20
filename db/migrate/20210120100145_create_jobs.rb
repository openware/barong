class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.references :reference, null: false, index: true, polymorphic: true

      # Can not use fieldname "type" for polymorphic table
      t.integer    :job_type, null: false # enum ( whitelist: 0, maintenance: 1, blacklist: 2, blocklogin: 3 )
      t.text       :description, limit: 5120, null: false
      t.integer    :state, null: false # enum ( pending: 0, active: 1, disabled: 2 )
      t.datetime   :start_at, null: false
      t.datetime   :finish_at, null: false
      t.timestamps
    end
  end
end
