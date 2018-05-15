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

  scope :with_private_scope, -> { where(scope: 'private') }

  validates :account_id, :key, :value, :scope, presence: true

  validates :scope,
            inclusion: { in: SCOPES.keys }

  validates :key,
            length: 3..255,
            format: { with: /\A[A-Za-z0-9_-]+\z/ },
            uniqueness: { scope: :account_id }

  validates :value,
            length: 3..255,
            format: { with: /\A[A-Za-z0-9_-]+\z/ }

  after_commit :update_level_if_label_defined, on: %i[create update]
  after_destroy :update_level_if_label_defined

private

  def update_level_if_label_defined
    return unless Level.exists?(key: key)
    account.reload.update_level
  end
end

# == Schema Information
# Schema version: 20180402133658
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
#  index_labels_on_key_and_value_and_account_id  (key,value,account_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id) ON DELETE => cascade
#
