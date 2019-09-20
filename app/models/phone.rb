# frozen_string_literal: true

#
# Class Phone
#
class Phone < ApplicationRecord
  TWILIO_CHANNELS = %w[call sms].freeze

  belongs_to :user

  validates :number, phone: true

  before_create :generate_code
  before_validation :parse_country
  before_validation :sanitize_number

  scope :verified, -> { where.not(validated_at: nil) }

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
#
# Table name: phones
#
#  id           :bigint           not null, primary key
#  user_id      :integer          unsigned, not null
#  country      :string(255)      not null
#  number       :string(255)      not null
#  code         :string(5)
#  validated_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_phones_on_number   (number)
#  index_phones_on_user_id  (user_id)
#
