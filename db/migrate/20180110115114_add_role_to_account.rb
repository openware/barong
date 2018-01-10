# frozen_string_literal: true

class AddRoleToAccount < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :role, :string, after: :encrypted_password, limit: 30, null: false, default: 'member'
  end
end
