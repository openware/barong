# frozen_string_literal: true

class AddMetadataToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :metadata, :text, after: :doc_expire
  end
end