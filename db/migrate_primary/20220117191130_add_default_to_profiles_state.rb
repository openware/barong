class AddDefaultToProfilesState < ActiveRecord::Migration[6.1]
  def change
    change_column_default :profiles, :state, 0
    change_column_null :profiles, :state, false
  end
end
