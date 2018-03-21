# frozen_string_literal: true

#
# Module for validation phones
#
module PhoneUtils
  class << self
    def sanitize(unsafe_phone)
      unsafe_phone.to_s.gsub(/\D/, '')
    end

    # Phone MUST contain international country code.
    def valid?(unsafe_phone)
      number = sanitize(unsafe_phone)
      phone  = Phonelib.parse(number)
      phone.valid? && phone.international(false) == number
    end
  end
end
