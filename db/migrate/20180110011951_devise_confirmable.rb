# frozen_string_literal: true

class DeviseConfirmable < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :confirmation_token, :string, after: :last_sign_in_ip
    add_column :accounts, :confirmed_at, :datetime, after: :confirmation_token
    add_column :accounts, :confirmation_sent_at, :datetime, after: :confirmed_at
  end
end
