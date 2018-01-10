class DeviseReconfirmable < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :unconfirmed_email, :string, after: :confirmation_sent_at
  end
end
