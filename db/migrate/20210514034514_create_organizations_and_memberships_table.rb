class CreateOrganizationsAndMembershipsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations do |t|
      t.string     :oid,                    null: false
      t.bigint     :parent_organization,    null: true
      t.string     :name,                   null: false
      t.string     :group,                  null: true
      t.string     :email,                  null: true
      t.string     :country,                null: true
      t.string     :city,                   null: true
      t.string     :phone,                  null: true
      t.string     :address,                null: true
      t.string     :postcode,               null: true
      t.string     :status,                 default: 'active', null: false
      t.timestamps
    end
    add_index :organizations, :oid, unique: true

    create_table :memberships do |t|
      t.belongs_to :user
      t.belongs_to :organization, null: false
      t.string     :role,         default: 'member', null: false
      t.timestamps
    end
  end
end
