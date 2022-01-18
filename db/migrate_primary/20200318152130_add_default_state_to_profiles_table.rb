class AddDefaultStateToProfilesTable < ActiveRecord::Migration[5.2]
  def change
    change_column_default :profiles, :state, 'drafted'
  end
end
