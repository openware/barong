# frozen_string_literal: true

#
# Class Phone
#
class Phone < ApplicationRecord
  include Encryptable

  TWILIO_CHANNELS = %w[call sms].freeze
  DEFAULT_COUNTRY_CODE_COUNT = 2

  belongs_to :user

  attr_encrypted :number
  validates :number, phone: true

  before_create :generate_code
  before_validation :parse_country
  before_validation :sanitize_number

  before_save :save_number_index

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

    def find_by_number(number, attrs={})
      attrs.merge!(number_index: SaltedCrc32.generate_hash(number))
      find_by(attrs)
    end

    def find_by_number!(number)
      find_by!(number_index: SaltedCrc32.generate_hash(number))
    end
  end

  def sub_masked_number
    code_count = parse_code&.length
    code_count = DEFAULT_COUNTRY_CODE_COUNT unless code_count

    if number.present?
      number.sub(/(?<=\A.{#{code_count}})(.*)(?=.{4}\z)/) { |match| '*' * match.length }
    else
      number
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

  def parse_code
    data = Phonelib.parse(number)
    data.country_code
  end

  def sanitize_number
    self.number = Phone.sanitize(number)
  end

  def save_number_index
    if number.present?
      self.number_index = SaltedCrc32.generate_hash(number)
    end
  end
end

# == Schema Information
#
# Table name: phones
#
#  id               :bigint           not null, primary key
#  user_id          :integer          unsigned, not null
#  country          :string(255)      not null
#  code             :string(5)
#  number_encrypted :string(255)      not null
#  number_index     :bigint           not null
#  validated_at     :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_phones_on_number_index  (number_index)
#  index_phones_on_user_id       (user_id)
#
