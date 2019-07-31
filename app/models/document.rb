# frozen_string_literal: true

# User document model
class Document < ApplicationRecord
  acts_as_eventable prefix: 'document', on: %i[create]

  mount_uploader :upload, UploadUploader

  TYPES = %w[passport passport-front passport-back
             identity-card identity-card-front identity-card-back
             driver-license driver-license-front driver-license-back
             faceid utility-bill ].freeze

  STATES = %w[verified pending rejected].freeze

  scope :kept, -> { joins(:user).where(users: { discarded_at: nil }) }

  belongs_to :user
  serialize :metadata, JSON
  validates :doc_type, :doc_number, :upload, presence: true
  validates :doc_type, inclusion: { in: TYPES }

  validates :doc_number, length: { maximum: 128 },
                         format: {
                           with: /\A[A-Za-z0-9\-\s]+\z/,
                           message: 'only allows letters and digits'
                         }, if: proc { |a| a.doc_number.present? }

  validate :doc_expire_not_in_the_past
  after_commit :create_or_update_document_label, on: :create

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

  private

  def doc_type
    read_attribute(:doc_type).try(:downcase)
  end

  def doc_expire_not_in_the_past
    return if doc_expire.blank?

    errors.add(:doc_expire, :invalid) if doc_expire < Date.current
  end

  def create_or_update_document_label
    user_document_label = user.labels.find_by(key: :document)
    if user_document_label.nil?
      user.labels.create(key: :document, value: :pending, scope: :private)
    elsif user_document_label.value != 'verified'
      user_document_label.update(value: :pending)
    end
  end
end
