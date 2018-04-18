# frozen_string_literal: true

module Vault
  # Vault::TOTP helper
  module TOTP
    class <<self
      ISSUER_NAME = 'Barong'

      def server_available?
        read_data('sys/health').present?
      rescue StandardError
        false
      end

      def otp_secret(otp)
        CGI.parse(URI.parse(otp.data[:url]).query)['secret'][0]
      end

      def safe_create(uid, email)
        return if exist?(uid)
        create(uid, email)
      end

      def create(uid, email)
        write_data(totp_key(uid),
                   generate: true,
                   issuer: ENV.fetch('APP_NAME', 'Barong'),
                   account_name: email,
                   qr_size: 300)
      end

      def exist?(uid)
        read_data(totp_key(uid)).present?
      end

      def validate?(uid, code)
        return false unless exist?(uid)
        write_data(totp_code_key(uid), code: code).data[:valid]
      end

      def delete(uid)
        delete_data(totp_key(uid))
      end

    private

      def totp_key(uid)
        "totp/keys/#{uid}"
      end

      def totp_code_key(uid)
        "totp/code/#{uid}"
      end

      def read_data(key)
        vault.read(key)
      end

      def write_data(key, params)
        vault.write(key, params)
      end

      def delete_data(key)
        vault.delete(key)
      end

      def vault
        Vault.logical
      end
    end
  end
end
