# frozen_string_literal: true

# Extend Vault
module Vault
  # Helpers for 2FA
  module TOTP
    class <<self

      ISSUER_NAME = 'Barong'

      # Make sure the key won't be regenerated
      def safe_create(uid)
        return if exist?(uid)
        create(uid)
      end

      # Check if OTP key already exists for given uid
      def exist?(uid)
        Vault.logical.read("totp/keys/#{uid}").present?
      end

      def validate?(uid, code)
        Vault.logical.write("totp/code/#{uid}", code: code).data[:valid]
      end

    private

      def create(uid)
        Vault.logical.write(
          "totp/keys/#{uid}",
          generate: true,
          issuer: ISSUER_NAME,
          account_name: uid,
          qr_size: 300
        )
      end

    end
  end
end
