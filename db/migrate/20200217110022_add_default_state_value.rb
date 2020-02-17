class AddDefaultStateValue < ActiveRecord::Migration[5.2]
  def change
    change_column :profiles, :state, :string, default: 'drafted', :null => false
  end
end
