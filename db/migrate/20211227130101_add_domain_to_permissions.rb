class AddDomainToPermissions < ActiveRecord::Migration[5.2]
  def change
    add_column :permissions, :domain, :string, null: false, default: DomainHost::DEFAULT_DOMAIN
  end
end
