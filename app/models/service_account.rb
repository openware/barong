# frozen_string_literal: true

# ServiceAccount model
class ServiceAccount < ApplicationRecord
  UID_PREFIX = 'SI'

  belongs_to :user, foreign_key: "owner_id", optional: true
  has_many :api_keys, as: :key_holder_account, dependent: :destroy, class_name: 'APIKey'

  validate :role_exists
  validate :email_n_uid_uniqueness
  validates :email, email: true, presence: true, uniqueness: true
  validates :uid, presence: true, uniqueness: true

  scope :active, -> { where(state: 'active') }

  after_update :disable_api_keys
  before_create :assign_state, if: -> { user.present? }
  # System will assign user state only if there is no changes of state during update
  before_update :assign_state, if: -> { user.present? && !state_changed? }
  before_validation :assign_level, if: -> { user.present? && !level_changed? }
  before_validation :assign_uid
  before_validation :assign_email

  def active?
    self.state == 'active'
  end

  def disable_api_keys
    if state_previously_changed? && state == 'disabled'
      api_keys.active.each do |key|
        key.update(state: 'inactive')
      end
    end
  end

  def as_payload
    as_json(only: %i[uid email role level state])
  end

  def role_exists
    return if Permission.pluck(:role).include?(role)

    errors.add(:role, 'doesnt_exist')
  end

  def email_n_uid_uniqueness
    errors.add('email_or_uid', 'not_uniq') if User.find_by(email: email) || User.find_by(uid: uid)
  end

  private

  def assign_email
    return unless email.blank?

    name, domain = user.email.split('@')
    self.email = "#{name}+#{self.uid}@#{domain}"
  end

  def assign_uid
    return unless uid.blank?

    self.uid = UIDGenerator.generate(UID_PREFIX)
  end

  def assign_state
    self.state = user.state
  end

  def update_state
    !state_changed?
  end

  def assign_level
    self.level = user.level
  end
end

# == Schema Information
# Schema version: 20210218135634
#
# Table name: service_accounts
#
#  id         :bigint           not null, primary key
#  uid        :string(255)      not null
#  owner_id   :bigint           unsigned
#  email      :string(255)      not null
#  role       :string(255)      default("service_account"), not null
#  level      :integer          default(0), not null
#  state      :string(255)      default("pending"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
