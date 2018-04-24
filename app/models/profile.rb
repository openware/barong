# frozen_string_literal: true

# Profile model
class Profile < ApplicationRecord
  STATES = %w[created pending approved rejected].freeze

  acts_as_eventable prefix: 'profile', on: %i[create update]

  belongs_to :account
  serialize :metadata, JSON
  validates :first_name, :last_name, :dob, :address, :city, :country, presence: true
  validates :state, inclusion: { in: STATES }
  after_update :set_level_if_state_changed
  after_create :set_account_level

  def as_json_for_event_api
    {
      account_uid: account.uid,
      first_name: first_name,
      last_name: last_name,
      dob: dob&.iso8601,
      address: address,
      postcode: postcode,
      city: city,
      country: country,
      state: state,
      metadata: metadata,
      created_at: created_at&.iso8601,
      updated_at: updated_at&.iso8601
    }
  end

private

  def set_account_level
    Label.set_level_for_account(account, 'profile_filled')
  end

  def set_level_if_state_changed
    if saved_change_to_state? && state == 'rejected'
      account.level_set(:phone)
      Label.set_level_for_account(account, 'profile_filled')
      ProfileReviewMailer.rejected(account).deliver_now
    elsif saved_change_to_state? && state == 'approved'
      account.level_set(:identity)
      ProfileReviewMailer.approved(account).deliver_now
    end
  end
end

# == Schema Information
# Schema version: 20180410093510
#
# Table name: profiles
#
#  id         :integer          not null, primary key
#  account_id :integer
#  first_name :string(255)
#  last_name  :string(255)
#  dob        :date
#  address    :string(255)
#  postcode   :string(255)
#  city       :string(255)
#  country    :string(255)
#  state      :string(255)      default("pending"), not null
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
#  fk_rails_...  (account_id => accounts.id)
#
