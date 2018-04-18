# frozen_string_literal: true

# Profile model
class Profile < ApplicationRecord
  belongs_to :account

  has_many :documents, dependent: :destroy
  validates :first_name, :last_name, :dob, :address, :city, :country, presence: true
  after_update :set_level_if_state_changed

private

  def set_level_if_state_changed
    if saved_change_to_state? && state == 'rejected'
      account.level_set(:phone)
      ProfileReviewMailer.rejected(account).deliver_now
    elsif saved_change_to_state? && state == 'approved'
      account.level_set(:identity)
      ProfileReviewMailer.approved(account).deliver_now
    end
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
