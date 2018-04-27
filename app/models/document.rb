# frozen_string_literal: true

#
# Document
#
class Document < ApplicationRecord
  mount_uploader :upload, UploadUploader

  TYPES = ['Passport', 'Identity card', 'Driver license'].freeze

  belongs_to :account
  validates :doc_type, :doc_number, :doc_expire, :upload, presence: true
  validates :doc_type, inclusion: { in: TYPES }

  validates :upload, length: { maximum: 10.megabytes }
  validates :doc_number, length: { maximum: 128 }
  validates_format_of :doc_expire,
                      with: /\d{4}\-\d{2}\-\d{2}/,
                      message: 'Date must be in the following format: yyyy-mm-dd'
  after_create :set_pending_if_rejected

private

  def set_pending_if_rejected
    account.profile.update(state: 'pending') if account.profile && account.profile.state == 'rejected'
  end
end

# == Schema Information
# Schema version: 20180402122730
#
# Table name: documents
#
#  id         :integer          not null, primary key
#  upload     :string(255)
#  doc_type   :string(255)
#  doc_number :string(255)
#  doc_expire :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :integer
#
# Indexes
#
#  index_documents_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
