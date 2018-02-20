class AddAutoAuthorized < ActiveRecord::Migration[5.1]
  def change
    add_column :oauth_applications, :autoauth, :boolean, default: false, after: :scopes
  end
end
