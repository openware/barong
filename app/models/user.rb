# frozen_string_literal: true

# User model
class User < ApplicationRecord
  acts_as_eventable prefix: 'user', on: %i[create update]

  has_secure_password

  has_many  :profiles,            dependent: :destroy
  has_many  :phones,              dependent: :destroy
  has_many  :data_storages,       dependent: :destroy
  has_many  :comments,            dependent: :destroy
  has_many  :documents,           dependent: :destroy
  has_many  :labels,              dependent: :destroy
  has_many  :activities,          dependent: :destroy
  has_many  :service_accounts,    dependent: :destroy, foreign_key: "owner_id"
  has_many  :api_keys,             dependent: :destroy, as: :key_holder_account, class_name: 'APIKey'

  validates_length_of :data, maximum: 1024
  validate :role_exists
  validate :referral_exists
  validates :data, data_is_json: true
  validates :email,       email: true, presence: true, uniqueness: true
  validates :username,    length: { minimum: 4, maximum: 12 }, format: { with: /\A[a-zA-Z0-9]+\z/ }, uniqueness: true, allow_nil: true
  validates :uid,         presence: true, uniqueness: true
  validates :password,    presence: true, if: :should_validate?
  validate  :validate_pass!

  scope :active, -> { where(state: 'active') }
  scope :with_pending_or_replaced_docs, -> { self.joins(:labels).where(labels:
                                           { key: 'document', value: ['pending', 'replaced'], scope: 'private' }) }

  before_validation :assign_uid, :downcase_username
  before_validation :generate_password, on: :create
  after_update :disable_api_keys
  after_update :disable_service_accounts

  def downcase_username
    username.downcase! unless username.nil?
  end

  def generate_password
    self.password = SecureRandom.base64(30) unless password
  end

  def validate_pass!
    return unless (new_record? && password.present?) || password.present?

    validation_result = PasswordStrengthChecker.validate!(password)
    errors.add(:password, validation_result) unless validation_result == 'strong'
  end

  def disable_service_accounts
    if state != 'active'
      service_accounts.each do |account|
        account.update(state: state)
      end
    end
  end

  def disable_api_keys
    if otp_previously_changed? && otp == false || state_previously_changed? && state != 'active'
      service_accounts.each do |service_account|
        service_account.api_keys.active.each do |key|
           key.update(state: 'inactive')
         end
      end
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
    BarongConfig.list['state_triggers']&.each do |state, triggers|
      triggers.each { |trigger|
        labels.pluck(:key).each { |label|
          @resulting_state = state if label == trigger
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
      username: username,
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
    as_json(only: %i[uid username email referral_id role level state])
  end

  def language
    if data.blank?
      Barong::App.config.default_language.upcase
    else
      JSON.parse(data)['language']&.upcase || Barong::App.config.default_language.upcase
    end
  end

  def submitted_profile
    self.profiles&.find_by(state: 'submitted')
  end

  def drafted_profile
    self.profiles&.find_by(state: 'drafted')
  end

  private

  def assign_uid
    return unless uid.blank?

    self.uid = UIDGenerator.generate(Barong::App.config.uid_prefix)
  end
end

# == Schema Information
# Schema version: 20210316083841
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  uid             :string(255)      not null
#  username        :string(255)
#  email           :string(255)      not null
#  password_digest :string(255)      not null
#  role            :string(255)      default("member"), not null
#  data            :text(65535)
#  level           :integer          default(0), not null
#  otp             :boolean          default(FALSE)
#  state           :string(255)      default("pending"), not null
#  referral_id     :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email     (email) UNIQUE
#  index_users_on_uid       (uid) UNIQUE
#  index_users_on_username  (username) UNIQUE
#
