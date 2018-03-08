# frozen_string_literal: true

# Profile model
class Profile < ApplicationRecord
  include AASM
  belongs_to :account

  has_many :documents, dependent: :destroy
  validates :first_name, :last_name, :dob, :address, :city, :country, presence: true

  aasm column: :state do
    state :pending, initial: true
    state :approved
    state :rejected

    event :approve, success: %i[set_account_level state_change_notify] do
      transitions from: :pending, to: :approved
    end

    event :reject, success: %i[set_account_level state_change_notify] do
      transitions from: %i[pending approved], to: :rejected
    end
  end

  def set_account_level
    account.level_set(approved? ? :identity : :phone)
  end

  def state_change_notify
    puts "Email: Hi #{first_name}, your account has been #{aasm.to_state}."
    ApplicationMailer.email_notify(account.email).deliver
  end

end

# == Schema Information
# Schema version: 20180126130155
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
