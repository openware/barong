# frozen_string_literal: true

class AddVerificationCode < ActiveRecord::Migration[5.1]
  def change
    add_column :phones, :code, :string, limit: 5, after: :validated_at, index: true
  end
end
