# frozen_string_literal: true

# Resposible for storing configurations
class Label < ApplicationRecord
  acts_as_eventable prefix: 'label', on: %i[create update]

  belongs_to :user

  SCOPES =
    HashWithIndifferentAccess.new(
      public: 'public', private: 'private'
    )

  SCOPES.keys.each do |name|
    define_method "#{name}?" do
      scope == SCOPES[name]
    end
  end

  scope :with_private_scope, -> { where(scope: 'private') }

  validates :user_id, :key, :value, :scope, presence: true
  validates :scope,
            inclusion: { in: SCOPES.keys }

  validates :key,
            length: 3..255,
            format: { with: /\A[a-z0-9_-]+\z/ },
            uniqueness: { scope: %i[user_id scope] }

  validates :value,
            length: 3..255,
            format: { with: /\A[a-z0-9_-]+\z/ }

  after_commit :update_state_if_label_defined, :update_level_if_label_defined, on: %i[create update]
  after_destroy :update_state_if_label_defined, :update_level_if_label_defined

  before_validation :normalize_fields

  def as_json_for_event_api
    {
      id: id,
      key: key,
      value: value,
      description: description,
      user: user.as_json_for_event_api
    }
  end

  private

  def normalize_fields
    self.key = key.to_s.downcase.squish
    self.value = value.to_s.downcase.squish
  end

  def update_state_if_label_defined
    return unless scope == 'private' || previous_changes[:scope]&.include?('private')

    user.update_state
  end

  def update_level_if_label_defined
    return unless scope == 'private' || previous_changes[:scope]&.include?('private')

    user.update_level
    send_document_review_notification if key == 'document'
  end

  # TODO: Fix it when EventAPI will be added.
  def send_document_review_notification
    if value == 'verified'
      EventAPI.notify('system.document.verified', record: as_json_for_event_api)
    elsif value == 'rejected'
      EventAPI.notify('system.document.rejected', record: as_json_for_event_api)
    end
  end
end

# == Schema Information
# Schema version: 20210325133233
#
# Table name: labels
#
#  id          :bigint           not null, primary key
#  user_id     :bigint           unsigned, not null
#  key         :string(255)      not null
#  value       :string(255)      not null
#  scope       :string(255)      default("public"), not null
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_labels_on_user_id                    (user_id)
#  index_labels_on_user_id_and_key_and_scope  (user_id,key,scope) UNIQUE
#
