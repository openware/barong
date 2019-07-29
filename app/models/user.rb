# frozen_string_literal: true

# User model
class User < ApplicationRecord
  acts_as_eventable prefix: 'user', on: %i[create update]

  has_secure_password

  has_one   :profile,    dependent: :destroy
  has_many  :phones,     dependent: :destroy
  has_many  :documents,  dependent: :destroy
  has_many  :labels,     dependent: :destroy
  has_many  :api_keys,   dependent: :destroy, class_name: 'APIKey'
  has_many  :activities, dependent: :destroy

  validate :role_exists
  validate :referral_exists
  validates :email,       email: true, presence: true, uniqueness: true
  validates :uid,         presence: true, uniqueness: true
  validates :password,    presence: true, if: :should_validate?,
                          required_symbols: true,
                          password_strength: { use_dictionary: true,
                                               min_entropy: 14 }

  scope :active, -> { where(state: 'active') }

  before_validation :assign_uid
  after_update :disable_api_keys

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

  def after_confirmation
    add_level_label(:email)
    self.state = 'active'
    save
  end

  # FIXME: Clean level micro code
  def update_level
    tags = []
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

  def add_level_label(key, value = 'verified')
    labels.find_or_create_by(key: key, scope: 'private')
          .update!(value: value)
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
    "%s%s" % [Barong::App.config.barong_uid_prefix.upcase, SecureRandom.hex(5).upcase]
  end
end
