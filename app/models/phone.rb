# frozen_string_literal: true

#
# Class Phone
#
class Phone < ApplicationRecord
  belongs_to :account

  validates :number, phone: { types: :mobile }

  before_validation :parse_country

  def validate_number!
    self.validate!
    if self.country != "AU"
      errors.add(:code, "Invalid country code.")
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end

  def validate_code!(original, confirm)
    if original != confirm
      errors.add(:code, "Invalid code.")
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end

  def send_sms(content)
    sid = Rails.application.secrets.twilio_account_sid
    token = Rails.application.secrets.twilio_auth_token
    from_phone = Rails.application.secrets.twilio_phone_number

    client = Twilio::REST::Client.new(sid, token)
    client.messages.create(
      from: from_phone,
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
