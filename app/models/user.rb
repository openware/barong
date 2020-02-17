# frozen_string_literal: true

# User model
class User < ApplicationRecord
  acts_as_eventable prefix: 'user', on: %i[create update]

  has_secure_password

  has_many  :profiles,      dependent: :destroy
  has_many  :phones,        dependent: :destroy
  has_many  :data_storages, dependent: :destroy
  has_many  :documents,     dependent: :destroy
  has_many  :labels,        dependent: :destroy
  has_many  :api_keys,      dependent: :destroy, class_name: 'APIKey'
  has_many  :activities,    dependent: :destroy

  validates_length_of :data, maximum: 1024
  validate :role_exists
  validate :referral_exists
  validates :data, data_is_json: true
  validates :email,       email: true, presence: true, uniqueness: true
  validates :uid,         presence: true, uniqueness: true
  validates :password,    presence: true, if: :should_validate?
  validate  :validate_pass!

  scope :active, -> { where(state: 'active') }

  before_validation :assign_uid
  after_update :disable_api_keys

  def validate_pass!
    return unless (new_record? && password.present?) || password.present?

    validation_result = PasswordStrengthChecker.validate!(password)
    errors.add(:password, validation_result) unless validation_result == 'strong'
  end

  def disable_api_keys
    if otp_previously_changed? && otp == false || state_previously_changed? && state != 'active'
      api_keys.active.each do |key|
        key.update(state: 'inactive')
      end
    end
  end

  def active?
    self.state == 'active'
  end

  def superadmin?
    self.role == 'superadmin'
  end

  def role_exists
    return if Permission.pluck(:role).include?(role)

    errors.add(:role, 'doesnt_exist')
  end

  # Check if refferal exist for assignment
  def referral_exists
    errors.add(:referral_id, 'doesnt_exist') if referral_id.present? && User.find_by(id: referral_id).blank?
  end

  def referral_uid
    user = User.find_by(id: referral_id)
    return if user.nil?

    user.uid
  end

  def role
    super.inquiry
  end

  def should_validate?
    new_record? || password.present?
  end

  # FIXME: Clean level micro code
  def update_level
    user_level = 0
    tags = labels.with_private_scope
                 .map { |l| [l.key, l.value].join ':' }

    levels = Level.all.order(id: :asc)
    levels.each do |lvl|
      break unless tags.include?(lvl.key + ':' + lvl.value)

      user_level = lvl.id
    end

    update(level: user_level)
  end

  def update_state
    @resulting_state = 'pending'

    # check if user has all required labels for activation
    if labels_include?(BarongConfig.list['activation_requirements'])
      @resulting_state = 'active'
    end

    # FIXME BarongConfig should be a feature of Barong::App
    BarongConfig.list['state_triggers'].each do |state, triggers|
      triggers.each { |trigger|
        labels.pluck(:key).each { |label|
          @resulting_state = state if label.start_with?(trigger)
        }
      }
    end

    update(state: @resulting_state) if @resulting_state != self.state
  end

  # check if given key: values hash is a subset of private user labels
  def labels_include?(labels_hash)
    labels_hash <= private_labels_to_hash
  end

  # Select all key-value pairs from user labels with private scope, merge in one hash
  def private_labels_to_hash
    key_value_arr = self.labels.with_private_scope.map do
      |l| { l.key => l.value }
    end
    key_value_hash = key_value_arr.inject(:merge)
    key_value_hash || {}
  end

  def as_json_for_event_api
    {
      uid: uid,
      email: email,
      role: role,
      level: level,
      otp: otp,
      state: state,
      referral_uid: referral_uid,
      created_at: format_iso8601_time(created_at),
      updated_at: format_iso8601_time(updated_at)
    }
  end

  def as_payload
    as_json(only: %i[uid email referral_id role level state])
  end

  private

  def assign_uid
    return unless uid.blank?

    loop do
      self.uid = random_uid
      break unless User.where(uid: uid).any?
    end
  end

  def random_uid
    "%s%s" % [Barong::App.config.uid_prefix.upcase, SecureRandom.hex(5).upcase]
  end
end

# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  data            :text(65535)
#  email           :string(255)      not null
#  level           :integer          default(0), not null
#  otp             :boolean          default(FALSE)
#  password_digest :string(255)      not null
#  role            :string(255)      default("member"), not null
#  state           :string(255)      default("pending"), not null
#  uid             :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  referral_id     :bigint
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#  index_users_on_uid    (uid) UNIQUE
#
