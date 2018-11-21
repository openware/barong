# frozen_string_literal: true

#
# Class Account
#
class Account < ApplicationRecord
  include Discard::Model
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :secure_validatable, :pwned_password,
         :confirmable, :lockable

  ROLES = %w[admin compliance member].freeze

  acts_as_eventable prefix: 'account', on: %i[create update]

  has_one :profile, dependent: :destroy
  has_many :phones, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :labels, dependent: :destroy
  has_many :api_keys, class_name: 'APIKey', dependent: :destroy

  before_validation :assign_uid

  validates :email, email: true
  validates :email, uniqueness: true
  validates :uid, presence: true, uniqueness: true

  scope :active, -> { where(state: 'active') }

  after_update :lock_if_attempts_count_exceeded

  def active_for_authentication?
    super && !discarded_at && state == 'active'
  end

  def role
    super.inquiry
  end

  def after_confirmation
    add_level_label(:email)
    self.state = 'active'
    save
  end

  def update_level
    tags = []
    account_level = 0
    tags = labels.with_private_scope
                 .map { |l| [l.key, l.value].join ':' }
    levels = Level.all.order(id: :asc)

    levels.each do |lvl|
      break unless tags.include?(lvl.key + ':' + lvl.value)
      account_level = lvl.id
    end

    update(level: account_level)
  end

  def add_level_label(key, value = 'verified')
    labels.find_or_create_by(key: key, scope: 'private')
          .update!(value: value)
  end

  def assign_uid
    return unless uid.blank?
    loop do
      self.uid = random_uid
      break unless Account.where(uid: uid).any?
    end
  end

  def random_uid
    "ID#{SecureRandom.hex(5).upcase}"
  end

  def add_failed_attempt
    update(failed_attempts: self.failed_attempts += 1)
  end

  def refresh_failed_attempts
    update(failed_attempts: 0)
  end

  def as_json_for_event_api
    {
      uid: uid,
      email: email,
      level: level,
      otp_enabled: otp_enabled,
      confirmation_token: confirmation_token,
      confirmed_at: format_iso8601_time(confirmed_at),
      confirmation_sent_at: format_iso8601_time(confirmation_sent_at),
      reset_password_sent_at: format_iso8601_time(reset_password_sent_at),
      state: state,
      failed_attempts: failed_attempts,
      locked_at: locked_at,
      created_at: format_iso8601_time(created_at),
      updated_at: format_iso8601_time(updated_at)
    }
  end

private

  def lock_if_attempts_count_exceeded
    return unless saved_changes.key? 'failed_attempts'
    lock_access! if failed_attempts >= ENV.fetch('MAX_LOGIN_ATTEMPTS', '5').to_i && locked_at.nil?
  end
end

# == Schema Information
# Schema version: 20180508095253
#
# Table name: accounts
#
#  id                     :integer          not null, primary key
#  uid                    :string(255)      not null
#  email                  :string(255)      not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  role                   :string(255)      default("member"), not null
#  level                  :integer          default(0), not null
#  otp_enabled            :boolean          default(FALSE)
#  state                  :string(255)      default("pending"), not null
#  discarded_at           :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_accounts_on_confirmation_token    (confirmation_token) UNIQUE
#  index_accounts_on_discarded_at          (discarded_at)
#  index_accounts_on_email                 (email) UNIQUE
#  index_accounts_on_reset_password_token  (reset_password_token) UNIQUE
#  index_accounts_on_uid                   (uid) UNIQUE
#  index_accounts_on_unlock_token          (unlock_token) UNIQUE
#
