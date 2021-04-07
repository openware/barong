class AddUserIpCountryFieldToActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :user_ip_country, :string, after: :user_ip
  end
end
