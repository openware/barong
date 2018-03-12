# frozen_string_literal: true

# Profile model
class Profile < ApplicationRecord
  belongs_to :account

  has_many :documents, dependent: :destroy
  validates :first_name, :last_name, presence: { :message => "is required."}
  validates :dob, presence: true, inclusion: { in: ( 70.years.ago ..18.years.ago), allow_blank: true,  message: "is invalid. Age must be between 18 and 70 years old"}
  validates :street_number, :street_name, :suburb, :postcode, :address_state, :country, presence: { :message => "is required."}
  validates_format_of :postcode, :with => /\A^\d{4}$\z/, allow_blank: true

end

# == Schema Information
# Schema version: 20180222010938
#
# Table name: profiles
#
#  id              :integer          not null, primary key
#  account_id      :integer
#  first_name      :string(255)
#  last_name       :string(255)
#  dob             :date
#  postcode        :string(255)
#  suburb          :string(255)
#  country         :string(255)
#  state           :string(255)      default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  middle_name     :string(255)
#  flat_number     :string(255)
#  street_number   :string(255)
#  street_name     :string(255)
#  street_type     :string(255)
#  address_state   :string(255)
#  green_id_status :string(255)
#
# Indexes
#
#  index_profiles_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
