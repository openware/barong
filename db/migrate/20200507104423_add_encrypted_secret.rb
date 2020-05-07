class AddEncryptedSecret < ActiveRecord::Migration[5.2]
  def change
    add_column :apikeys, :secret_encrypted, :string, limit: 1024, after: :scope
  end
end
