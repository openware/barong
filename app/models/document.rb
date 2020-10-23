# frozen_string_literal: true

# User document model
class Document < ApplicationRecord
  include Encryptable

  acts_as_eventable prefix: 'document', on: %i[create]

  mount_uploader :upload, Barong::App.config.uploader

  STATES = %w[verified pending replaced rejected].freeze

  attr_encrypted :doc_number

  belongs_to :user

  validates :doc_type, :upload, presence: true
  validates :doc_type, inclusion: { in: DocumentTypes.list }
  validates :doc_expire, presence: true, if: -> { Barong::App.config.required_docs_expire }
  validates :metadata, data_is_json: true

  validates :doc_number, length: { maximum: 128 },
                         format: {
                           with: /\A[A-Za-z0-9\-\s]+\z/,
                           message: 'only allows letters and digits'
                         }, if: proc { |a| a.doc_number.present? }

  validate :doc_expire_not_in_the_past, if: -> { Barong::App.config.required_docs_expire }
  after_commit :start_document_kyc_verification, on: :create
  before_save :save_doc_number_index

  attr_writer :update_labels

  def as_json_for_event_api
    {
      user: user.as_json_for_event_api,
      upload: CGI::escape(upload.url),
      doc_type: doc_type,
      doc_number: doc_number,
      doc_expire: doc_expire,
      metadata: metadata,
      created_at: format_iso8601_time(created_at),
      updated_at: format_iso8601_time(updated_at)
    }
  end

  def sub_masked_doc_number
    doc_number.sub(/(?<=\A.{2})(.*)(?=.{2}\z)/) { |match| '*' * match.length } if doc_number
  end

  private

  def start_document_kyc_verification
    KycService.document_step(self)
  end

  def update_labels
    @update_labels.nil? ? true : @update_labels
  end

  def doc_expire_not_in_the_past
    return if doc_expire.blank?

    errors.add(:doc_expire, :invalid) if doc_expire < Date.current
  end

  def save_doc_number_index
    if doc_number.present?
      self.doc_number_index = SaltedCrc32.generate_hash(doc_number)
    end
  end
end

# == Schema Information
#
# Table name: documents
#
#  id                   :bigint           not null, primary key
#  user_id              :bigint           unsigned, not null
#  upload               :string(255)
#  doc_type             :string(255)
#  doc_expire           :date
#  doc_number_encrypted :string(255)
#  doc_number_index     :bigint
#  doc_issue            :date
#  doc_category         :string(255)
#  identificator        :string(255)
#  metadata             :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_documents_on_doc_number_index  (doc_number_index)
#  index_documents_on_user_id           (user_id)
#
