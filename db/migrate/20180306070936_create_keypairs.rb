# frozen_string_literal: true

class CreateKeypairs < ActiveRecord::Migration[5.1]
  def change
    create_table :keypairs do |t|
      t.string    :label
      t.string    :access_key
      t.string    :secret_key
      t.string    :trusted_ip_list
      t.string    :scopes

      t.datetime  :expires_at
      t.datetime  :deleted_at

      t.integer   :rate_limit

      t.timestamps
    end
  end
end
