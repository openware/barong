class CreateJobbings < ActiveRecord::Migration[5.2]
  def change
    create_table :jobbings do |t|
      t.references :job,       null: false, index: true
      t.references :reference, null: false, index: true, polymorphic: true

      t.timestamps
    end
  end
end
