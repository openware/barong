# frozen_string_literal: true

# Profile model
class Profile < ApplicationRecord
  acts_as_eventable prefix: 'profile', on: %i[create update]

  belongs_to :account
  serialize :metadata, JSON
  validates :first_name, :last_name, :dob, :address,
            :city, :country, :postcode, presence: true

  validates :first_name, length: 2..255,
                         format: {
                           with: /\A[A-Za-z\s'-]+\z/,
                           message: 'only allows letters "-", "\'", and space'
                         },
                         if: proc { |a| a.first_name.present? }
  validates :last_name, length: 2..255,
                        format: {
                          with: /\A[A-Za-z\s'-]+\z/,
                          message: 'only allows letters "-", "\'" and space'
                        },
                        if: proc { |a| a.last_name.present? }
  validates :city, length: 2..255,
                   format: {
                     with: /\A[A-Za-z\s'-]+\z/
                   },
                   if: proc { |a| a.city.present? }
  validate :validate_country_format
  validates :postcode, length: 2..255,
                       format: { with: /\A[A-Z\d\s-]+\z/ },
                       if: proc { |a| a.postcode.present? }

  validates :address, format: { with: /\A[A-Za-z\d\s\.,']+\z/ },
                      if: proc { |a| a.address.present? }

  scope :kept, -> { joins(:account).where(accounts: { discarded_at: nil }) }
  before_validation :squish_spaces

  def full_name
    "#{first_name} #{last_name}"
  end

  def as_json_for_event_api
    {
      account_uid: account.uid,
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

# == Schema Information
# Schema version: 20180907133821
#
# Table name: profiles
#
#  id         :bigint(8)        not null, primary key
#  account_id :bigint(8)
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
# Indexes
#
#  index_profiles_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_f44be28d09  (account_id => accounts.id)
#
