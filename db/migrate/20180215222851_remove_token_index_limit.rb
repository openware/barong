# frozen_string_literal: true

class RemoveTokenIndexLimit < ActiveRecord::Migration[5.1]
  def change
    remove_index  :oauth_access_tokens, :token if index_exists?(:oauth_access_tokens, :token)
    change_column :oauth_access_tokens, :token, :string, null: false, index: { unique: true }, limit: 1024
  end
end
