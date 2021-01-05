# frozen_string_literal: true

module Barong
  class KeyStore

    class Fatal < StandardError; end

    def initialize(private_key)
      OpenSSL::PKey.read(private_key).tap do |key|
        @private_key = key
        @public_key = key.public_key
      end
    end

    def public_key
      @public_key
    end

    def private_key
      @private_key
    end

    class << self
      def open!(private_key_path)
        pkeyio = File.open(private_key_path)
        return OpenSSL::PKey.read(pkeyio).to_pem
      rescue
        raise Barong::KeyStore::Fatal
      end

      def read!(private_key)
        return OpenSSL::PKey.read(private_key).to_pem
      rescue
        raise Barong::KeyStore::Fatal
      end

      def save!(key, path)
        File.open(path, 'w+') { |file| file.write(key) }
      rescue
        raise Barong::KeyStore::Fatal
      end

      def generate
        OpenSSL::PKey::RSA.generate(2048)
      end
    end

  end
end
