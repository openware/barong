# frozen_string_literal: true

class ChangeDocumentsReferenceFromProfileToAccount < ActiveRecord::Migration[5.1]
  def change
    add_reference :documents, :account, foreign_key: true, after: :id
    remove_foreign_key :documents, :profiles
    remove_reference :documents, :profile, index: true
  end
end
