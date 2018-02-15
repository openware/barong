# frozen_string_literal: true

class DeviseCreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      ## Database authenticatable
      t.string :uid,                null: false,  unique: true
      t.string :email,              null: false
      t.string :encrypted_password, null: false, default: ''

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      t.string   :role, null: false, default: 'member'
      t.integer  :level, null: false, default: 0
      t.string   :state, null: false, default: 'pending'

      t.timestamps null: false
    end

    add_index :accounts, :uid,                  unique: true
    add_index :accounts, :email,                unique: true
    add_index :accounts, :reset_password_token, unique: true
    add_index :accounts, :confirmation_token,   unique: true
    add_index :accounts, :unlock_token,         unique: true
  end
end
