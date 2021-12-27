class CreateDomainHosts < ActiveRecord::Migration[5.2]
  def change
    create_table :domain_hosts do |t|
      t.string :domain, null: false
      t.string :host, null: false
    end

    add_index :domain_hosts, :host, unique: true
  end
end
