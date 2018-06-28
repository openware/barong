# frozen_string_literal: true

# Resposible for storing configurations
class Label < ApplicationRecord
  belongs_to :account

  SCOPES =
    HashWithIndifferentAccess.new(
      public: 'public', private: 'private'
    )

  SCOPES.keys.each do |name|
    define_method "#{name}?" do
      scope == SCOPES[name]
    end
  end

  scope :kept, -> { joins(:account).where(accounts: { discarded_at: nil }) }

  scope :with_private_scope, -> { where(scope: 'private') }

  validates :account_id, :key, :value, :scope, presence: true

  validates :scope,
            inclusion: { in: SCOPES.keys }

  validates :key,
            length: 3..255,
            format: { with: /\A[a-z0-9_-]+\z/ },
            uniqueness: { scope: %i[account_id scope] }

  validates :value,
            length: 3..255,
            format: { with: /\A[a-z0-9_-]+\z/ }

  after_commit :update_level_if_label_defined, on: %i[create update]
  after_destroy :update_level_if_label_defined
  before_validation :normalize_fields

private

  def normalize_fields
    self.key = key.to_s.downcase.squish
    self.value = value.to_s.downcase.squish
  end

  def update_level_if_label_defined
    return unless scope == 'private' || previous_changes[:scope]&.include?('private')
    account.reload.update_level
    send_document_review_notification if key == 'document'
  end

  def send_document_review_notification
    if value == 'verified'
      ProfileReviewMailer.approved(account).deliver_now
      EventAPI.notify('system.document.verified', uid: account.uid, email: account.email)
    elsif value == 'rejected'
      ProfileReviewMailer.rejected(account).deliver_now
      EventAPI.notify('system.document.rejected', uid: account.uid, email: account.email)
    end
  end
end

# == Schema Information
# Schema version: 20180507162420
#
# Table name: labels
#
#  id         :integer          not null, primary key
#  account_id :integer
#  key        :string(255)      not null
#  value      :string(255)      not null
#  scope      :string(255)      default("public"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_labels_on_account_id                    (account_id)
#  index_labels_on_key_and_scope_and_account_id  (key,scope,account_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id) ON DELETE => cascade
#
