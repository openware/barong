# frozen_string_literal: true

# == Schema Information
#
# Table name: service_accounts
#
#  id          :bigint           not null, primary key
#  uid         :string(255)      not null
#  provider_id :bigint           unsigned, not null
#  email       :string(255)      not null
#  role        :string(255)      default("service_account"), not null
#  level       :integer          default(0), not null
#  state       :string(255)      default("pending"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#


# ServiceAccount model
class ServiceAccount < ApplicationRecord
  belongs_to :user, foreign_key: "provider_id"
  has_many :api_keys, as: :key_holder_account, dependent: :destroy, class_name: 'APIKey'

  validate :provider_role
  validate :role_exists
  validate :email_n_uid_uniqueness
  validates :email,       email: true, presence: true, uniqueness: true
  validates :uid,         presence: true, uniqueness: true

  scope :active, -> { where(state: 'active') }

  after_update :disable_api_keys
  before_validation :assign_state_level
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

  def provider_role
    errors.add(:provider_id, 'is not provider role') if self.user.role != 'provider'
  end

  def email_n_uid_uniqueness
    errors.add('email_or_uid', 'not_uniq') if User.find_by(email: email) || User.find_by(uid: uid)
  end

  private

  def assign_email
    return unless email.blank?

    self.email = "service+#{user.service_accounts.count}+" + user.email
  end

  def assign_uid
    return unless uid.blank?

    loop do
      self.uid = random_uid
      break unless User.where(uid: uid).any? || ServiceAccount.where(uid: uid).any?
    end
  end

  def random_uid
    "%s%s" % ["SI", SecureRandom.hex(5).upcase]
  end

  def assign_state_level
    self.state = user.state
    self.level = user.level
  end
end
