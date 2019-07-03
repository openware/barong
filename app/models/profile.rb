# frozen_string_literal: true
# == Schema Information
#
# Table name: profiles
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)
#  first_name :string(255)
#  last_name  :string(255)
#  dob        :date
#  address    :string(255)
#  postcode   :string(255)
#  city       :string(255)
#  country    :string(255)
#  metadata   :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Profile model
class Profile < ApplicationRecord
  acts_as_eventable prefix: 'profile', on: %i[create]

  belongs_to :user
  serialize :metadata, JSON
  validates :first_name, :last_name, :dob, :address,
            :city, :country, :postcode, presence: true

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
  validate :validate_country_format
  validates :postcode, length: 2..255,
                       format: {
                         with: /\A[[:word:]\s\-]+\z/,
                         message: 'only allows letters, digits, "-" and space'
                       },
                       if: proc { |a| a.postcode.present? }

  validates :address, length: 1..255,
                      format: {
                        with: /\A[[:word:]\s\-']+\z/,
                        message: 'only allows letters, digits "-", "\'", and space'
                      },
                      if: proc { |a| a.address.present? }

  scope :kept, -> { joins(:user).where(users: { discarded_at: nil }) }
  before_validation :squish_spaces

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

  def validate_country_format
    return if ISO3166::Country.find_country_by_alpha2(country) ||
              ISO3166::Country.find_country_by_alpha3(country)

    errors.add(:country, 'must have alpha2 or alpha3 format')
  end

  def squish_spaces
    first_name&.squish!
    last_name&.squish!
    city&.squish!
    postcode&.squish!
  end
end
