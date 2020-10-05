# frozen_string_literal: true

class EncryptionService
  delegate :encrypt_and_sign, :decrypt_and_verify, to: :encryptor
  
  def self.current_salt
    Time.now.strftime("%Y%W")
  end
  
  def self.pack(salt, value)
    [salt, value].join(".")
  end

  def self.unpack(str)
    raise "Invalid encrypted value: #{str}" unless str =~ (/([^.])\.(.*)/
    [$1, $2]
  end
    
  def self.get_key(salt)
    @cache ||= {}
    unless @cache[salt]
    @cache[salt] = ActiveSupport::KeyGenerator.new(
        ENV.fetch('SECRET_KEY_BASE')
    ).generate_key(salt, ActiveSupport::MessageEncryptor.key_len).freeze
    end
    @cache[salt]
  end

  def self.encrypt(value)
    # TODO: get_key and pack
    new.encrypt_and_sign(value)
  end

  def self.decrypt(value)
    # TODO: unpack and get_key
    new.decrypt_and_verify(value)
  end

  private

  def encryptor
    ActiveSupport::MessageEncryptor.new(KEY)
  end
end
