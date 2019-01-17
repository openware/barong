# frozen_string_literal: true

#
# Class Phone
#
class Phone < ApplicationRecord
  belongs_to :user

  validates :number, phone: true

  before_create  :generate_code
  before_validation :parse_country
  before_validation :sanitize_number

  scope :verified, -> { where.not(validated_at: nil) }

  def regenerate_code
    generate_code
    save
  end

  #FIXME: Clean code below
  class << self
    def sanitize(unsafe_phone)
      unsafe_phone.to_s.gsub(/\D/, '')
    end

    def parse(unsafe_phone)
      Phonelib.parse self.sanitize(unsafe_phone)
    end

    def valid?(unsafe_phone)
      parse(unsafe_phone).valid?
    end

    def international(unsafe_phone)
      parse(unsafe_phone).international(false)
    end

    def send_confirmation_sms(phone)
      Rails.logger.info("Sending SMS to #{phone.number}")

      app_name = Barong::App.config.app_name
      send_sms(number: phone.number,
               content: "Your verification code for #{app_name}: #{phone.code}")
    end

    def send_sms(number:, content:)
      from_phone = Barong::App.config.twilio_phone_number

      client = Barong::App.config.sms_sender
      client.messages.create(
        from: from_phone,
        to:   '+' + number,
        body: content
      )
    end
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
    self.number = Phone.sanitize(number)
  end
end

# == Schema Information
# Schema version: 20180503073934
#
# Table name: phones
#
#  id           :integer          not null, primary key
#  country      :string(255)
#  number       :string(255)      not null
#  validated_at :datetime
#  code         :string(5)
#  user_id      :integer             unsigned, not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_phones_on_user_id     (user_id)
#  index_phones_on_number      (number)
#
