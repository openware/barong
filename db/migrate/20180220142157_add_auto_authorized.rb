# frozen_string_literal: true

class AddAutoAuthorized < ActiveRecord::Migration[5.1]
  def change
    add_column :oauth_applications, :skipauth, :boolean, default: false, after: :scopes
  end
end
