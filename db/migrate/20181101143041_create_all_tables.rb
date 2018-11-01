class CreateAllTables < ActiveRecord::Migration[5.2]
  def change

    create_table :users do |t|
      t.string    :uid,                 null: false
      t.string    :email,               null: false
      t.string    :password_digest,     null: false
      t.string    :role,                default: "member", null: false
      t.integer   :level,               default: 0, null: false
      t.boolean   :otp,                 default: false
      t.string    :state,               default: "pending", null: false
      t.timestamps
    end
    add_index :users, :uid, unique: true
    add_index :users, :email, unique: true

    create_table :apikeys do |t|
      t.bigint    :user_id,   null: false, unsigned: true
      t.string    :kid,       null: false
      t.string    :algorithm, null: false
      t.string    :scope
      t.string    :state, default: "active", null: false
      t.timestamps
      t.index [:user_id]
    end

    create_table :documents do |t|
      t.bigint    :user_id, null: false, unsigned: true
      t.string    :upload
      t.string    :doc_type
      t.string    :doc_number
      t.date      :doc_expire
      t.text      :metadata
      t.timestamps
      t.index [:user_id]
    end

    create_table :labels do |t|
      t.bigint  :user_id, null: false, unsigned: true
      t.string  :key,     null: false
      t.string  :value,   null: false
      t.string  :scope,   default: "public", null: false
      t.timestamps
      t.index [:user_id]
      t.index [:user_id, :key, :scope]
    end

    create_table :levels do |t|
      t.string  :key, null: false
      t.string  :value
      t.string  :description
      t.timestamps
    end

    create_table :phones do |t|
      t.integer   :user_id, null: false, unsigned: true
      t.string    :country, null: false
      t.string    :number,  null: false
      t.string    :code,    limit: 5
      t.datetime  :validated_at
      t.timestamps
      t.index [:user_id]
      t.index [:number]
    end

    create_table :profiles do |t|
      t.bigint    :user_id
      t.string    :first_name
      t.string    :last_name
      t.date      :dob
      t.string    :address
      t.string    :postcode
      t.string    :city
      t.string    :country
      t.text      :metadata
      t.timestamps
      t.index [:user_id]
    end

  end
end
