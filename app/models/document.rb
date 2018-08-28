# frozen_string_literal: true

#
# Document
#
class Document < ApplicationRecord

  # commented old uploader for reference
  # mount_uploader :upload, UploadUploader
  has_one_attached :upload

  TYPES = ['Passport', 'Identity card', 'Driver license', 'Utility Bill'].freeze
  STATES = %w[verified pending rejected].freeze

  scope :kept, -> { joins(:account).where(accounts: { discarded_at: nil }) }

  belongs_to :account
  serialize :metadata, JSON
  validates :doc_type, :doc_number, :doc_expire, :upload, presence: true
  validates :doc_type, inclusion: { in: TYPES }

  validates :upload, length: { maximum: 10.megabytes }
  validates :doc_number, length: { maximum: 128 }
  validates_format_of :doc_expire,
                      with: /\A\d{4}\-\d{2}\-\d{2}\z/,
                      message: 'Date must be in the following format: yyyy-mm-dd'
  after_commit :create_or_update_document_label, on: :create

private

  def create_or_update_document_label
    account_document_label = account.labels.find_by(key: :document)
    if account_document_label.nil?
      account.labels.create(key: :document, value: :pending, scope: :private)
    elsif account_document_label.value != 'verified'
      account_document_label.update(value: :pending)
    end
  end
end

# == Schema Information
# Schema version: 20180507095118
#
# Table name: documents
#
#  id         :integer          not null, primary key
#  account_id :integer
#  upload     :string(255)
#  doc_type   :string(255)
#  doc_number :string(255)
#  doc_expire :date
#  metadata   :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_documents_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
