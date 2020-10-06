# frozen_string_literal: true

class EncryptionService
  # Example: 202040
  # Week number starts from 0
  def self.current_salt
    Time.now.strftime('%Y%W')
  end

  def self.pack(salt, value)
    [salt, value].join('.')
  end

  def self.unpack(str)
    raise "Invalid encrypted value: #{str}" unless str =~ (/(\w*)\.(.*)/)
    [$1, $2]
  end

  def self.encrypt(value)
    # Get current salt
    salt = current_salt
    # Get or generate new master key from salt
    current_key = get_master_key(salt)
    # Encrypt attribute value
    encrypted_key = encryptor(current_key).encrypt_and_sign(value)
    # Add salt before encrypted value
    pack(salt, encrypted_key)
  end

  def self.decrypt(value)
    # Unpack salt and encrypted_key
    salt, encrypted_key = unpack(value)
    # Get master key from salt
    master_key = get_master_key(salt)
    # Decrypt encrypted value for attribute
    encryptor(master_key).decrypt_and_verify(encrypted_key)
  end

  private

  def self.encryptor(key)
    ActiveSupport::MessageEncryptor.new(key)
  end

  def self.get_master_key(salt)
    @cache ||= {}
    unless @cache[salt]
      @cache[salt] = ActiveSupport::KeyGenerator.new(
        ENV.fetch('SECRET_KEY_BASE')
      ).generate_key(salt, ActiveSupport::MessageEncryptor.key_len)
    end

    @cache[salt]
  end
end
