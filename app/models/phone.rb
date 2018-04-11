# frozen_string_literal: true

#
# Phone Verification module
#
module PhoneVerification
  extend ActiveSupport::Concern

  included do
    attr_accessor :verification_code, :submitted_verification_code

    validate do
      if verification_code.present? && submitted_verification_code.present?
        errors.add(:verification_code, :invalid) unless verification_code == submitted_verification_code
      end
    end
  end
end

#
# Class Phone
#
class Phone < ApplicationRecord
  include PhoneVerification

  belongs_to :account

  validates :number, phone: true

  before_validation :parse_country
  before_validation :sanitize_number
  after_initialize :generate_code

  scope :verified, -> { where.not(validated_at: nil) }

  def number_exists?
    Phone.verified.exists?(number: number)
  end

private

  def generate_code
    self.code = rand.to_s[2..6]
  end

  def parse_country
    data = Phonelib.parse(number)
    self.country = data.country
  end

  def sanitize_number
    self.number = PhoneUtils.sanitize(number)
  end
end

# == Schema Information
# Schema version: 20180404153832
#
# Table name: phones
#
#  id           :integer          not null, primary key
#  country      :string(255)
#  number       :string(255)      not null
#  validated_at :datetime
#  account_id   :integer          unsigned, not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  code         :string(5)
#
# Indexes
#
#  index_phones_on_account_id  (account_id)
#  index_phones_on_number      (number) UNIQUE
#
