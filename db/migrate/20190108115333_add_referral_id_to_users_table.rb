# frozen_string_literal: true

# Add new field due to referral - affiliate relation
class AddReferralIdToUsersTable < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :referral_id, :bigint, after: :state
  end
end
