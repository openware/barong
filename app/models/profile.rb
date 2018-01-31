# frozen_string_literal: true

# Profile model
class Profile < ApplicationRecord
  belongs_to :account

  has_many :documents, dependent: :destroy
  validates :first_name, :last_name, :dob, :address, :city, :country, presence: true
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
