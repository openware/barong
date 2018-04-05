# frozen_string_literal: true

class AddMetadataColumnToProfiles < ActiveRecord::Migration[5.1]
  def change
    add_column :profiles, :metadata, :text, after: :state
  end
end
