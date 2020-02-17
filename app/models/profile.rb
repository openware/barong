# frozen_string_literal: true
# == Schema Information
#
# Table name: profiles
#
#  id         :bigint           not null, primary key
#  user_id    :bigint
#  first_name :string(255)
#  last_name  :string(255)
#  dob        :date
#  address    :string(255)
#  postcode   :string(255)
#  city       :string(255)
#  country    :string(255)
#  state      :integer          unsigned
#  metadata   :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_profiles_on_user_id  (user_id)
#

# Profile model
class Profile < ApplicationRecord
  acts_as_eventable prefix: 'profile', on: %i[create update]

  belongs_to :user
  validates :state, presence: true

  OPTIONAL_PARAMS = %w[first_name last_name dob address postcode city country].freeze

  validates :first_name, length: 1..255,
                         format: {
                           with: /\A[[:word:]\s\-']+\z/,
                           message: 'only allows letters, digits "-", "\'", and space'
                         },
                         if: proc { |a| a.first_name.present? }
  validates :last_name, length: 1..255,
                        format: {
                          with: /\A[[:word:]\s\-']+\z/,
                          message: 'only allows letters, digits "-", "\'", and space'
                        },
                        if: proc { |a| a.last_name.present? }
  validates :city, length: 1..255,
                   format: {
                     with: /\A[[:word:]\s\-']+\z/,
                     message: 'only allows letters, digits "-", "\'", and space'
                   },
                   if: proc { |a| a.city.present? }
  validate :validate_country_format, if: ->(p) { p.country.present? }
  validates :postcode, length: 2..255,
                       format: {
                         with: /\A[[:word:]\s\-]+\z/,
                         message: 'only allows letters, digits, "-" and space'
                       },
                       if: proc { |a| a.postcode.present? }

  validates :address, length: 1..255,
                      format: {
                        with: /\A[[:word:]\s\-,\.;\/:\#"\\&\')\(]+\z/,
                        message: 'only allows letters, digits "-", "\'", and space'
                      },
                      if: proc { |a| a.address.present? }
  validates :metadata, data_is_json: true
  validate  :profile_state!, on: :create

  before_validation do
    assign_state
    squish_spaces
  end

  after_commit :create_profile_label, on: :create

  def full_name
    "#{first_name} #{last_name}"
  end

  def as_json_for_event_api
    {
      user: user.as_json_for_event_api,
      first_name: first_name,
      last_name: last_name,
      dob: format_iso8601_time(dob),
      address: address,
      postcode: postcode,
      city: city,
      country: country,
      metadata: metadata,
      created_at: format_iso8601_time(created_at),
      updated_at: format_iso8601_time(updated_at)
    }
  end

  private

  def profile_state!
    # No limits for storing approved and rejected profiles
    return if state.in?(%w[approved rejected]) || self.user.nil?

    # This check is actual for profile states [drafted submitted]
    # User cant have more than one DRAFTED or SUMBITTED profile at one time
    user_profiles_states = self.user.profiles.pluck(:state)
    if user_profiles_states.include?('drafted') ||  user_profiles_states.include?('submitted')
      errors.add(:state, :exists, message: 'already exists')
    end
  end

  def assign_state
    state = self.state ||= 'drafted'
  end

  def readonly?
    # allow update if profile.state is drafted or record is new(stadard behaviour)
    return false if new_record? || self.state == 'drafted' # false

    # readonly for submitted approved rejected
    true
  end

  def validate_country_format
    return if ISO3166::Country.find_country_by_alpha2(country) ||
              ISO3166::Country.find_country_by_alpha3(country)

    errors.add(:country, 'must have alpha2 or alpha3 format')
  end

  def squish_spaces
    first_name&.squish!
    last_name&.squish!
    postcode&.squish!
    city&.squish!
  end

  def create_profile_label
    user.labels.create(key: 'profile', value: 'drafted', scope: 'private')
  end
end
