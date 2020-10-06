# frozen_string_literal: true

class SaltedCrc32
  def self.generate_hash(value)
    Zlib::crc32(value + Barong::App.config.crc32_salt)
  end
end
