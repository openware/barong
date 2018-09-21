# frozen_string_literal: true

module Vault
  # Vault::TOTP helper
  module TOTP
    Error = Class.new(StandardError)

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

      def with_human_error
        raise ArgumentError, 'Block is required' unless block_given?
        yield
      rescue Vault::VaultError => e
        Rails.logger.error { e }
        if e.message.include?('connection refused')
          raise Error, '2FA server is under maintenance'
        end

        if e.message.include?('code already used')
          raise Error, 'This code was already used. Wait until the next time period'
        end

        raise e
      end

    private

      def totp_key(uid)
        "totp/keys/#{uid}"
      end

      def totp_code_key(uid)
        "totp/code/#{uid}"
      end

      def read_data(key)
        with_human_error do
          vault.read(key)
        end
      end

      def write_data(key, params)
        with_human_error do
          vault.write(key, params)
        end
      end

      def delete_data(key)
        with_human_error do
          vault.delete(key)
        end
      end

      def vault
        Vault.logical
      end
    end
  end
end
