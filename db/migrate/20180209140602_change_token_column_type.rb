# frozen_string_literal: true

class ChangeTokenColumnType < ActiveRecord::Migration[5.1]
  def up
    remove_index  :oauth_access_tokens, :token
    change_column :oauth_access_tokens, :token, :text, limit: 5.kilobytes
    add_index     :oauth_access_tokens, :token, unique: true, length: 255
  end

  def down
    remove_index  :oauth_access_tokens, :token
    change_column :oauth_access_tokens, :token, :string, limit: nil
    add_index     :oauth_access_tokens, :token, unique: true
  end
end
