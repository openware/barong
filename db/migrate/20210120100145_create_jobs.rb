class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      # reference: polymorphic: true, can be null (for this story reference will be Restriction)
      # type (default: maintenance)
      # start_at (optional)
      # finish_at (optional)
      # description
      # status (pending, active, disabled)

      # Here you can also think and suggest you opinion - there are two options
      # 1. We adding reference here (it will be more flexible if we will add more type of Jobs)
      #
      # 2. We add job_id to Restricions table and then we will be able to have few Restrictions e.g:
      # - Restriction for maintenance
      # - Restriction for whitelist IP
      # Then it will be more ease to manage Restrictions through existing Job
      t.references :reference, null: false, index: true, polymorphic: true



      t.integer    :type, null: false # enum
      t.text       :description, limit: 5120, null: false
      t.integer    :state, null: false # enum
      t.datetime   :start_at, null: false
      t.datetime   :finish_at, null: false
      t.timestamps
    end
  end
end
