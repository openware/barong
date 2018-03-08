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

  def number_exists?
    sanitized_number = Phonelib.parse(number).sanitized
    Phone.exists?(number: sanitized_number)
  end

  def send_sms(content)
    sid = Rails.application.secrets.twilio_account_sid
    token = Rails.application.secrets.twilio_auth_token
    client = Twilio::REST::Client.new(sid, token)
    client.messages.create(
      from: Rails.application.secrets.twilio_phone_number,
      to:   number,
      body: content
    )
  end

  def generate_code
    rand.to_s[2..6]
  end

  def parse_country
    data = Phonelib.parse(number)
    self.country = data.country
  end

end

# == Schema Information
# Schema version: 20180126130155
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
#
# Indexes
#
#  index_phones_on_account_id  (account_id)
#  index_phones_on_number      (number) UNIQUE
#
