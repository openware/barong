# frozen_string_literal: true

module API::V2
  module Entities
    class APIKey < Grape::Entity
      format_with(:iso_timestamp) { |d| d.utc.iso8601 }

      expose :kid, documentation: { type: 'String', desc: 'jwt public key' }
      expose :algorithm, documentation: { type: 'String', desc: 'cryptographic hash function type' }
      expose :scope, documentation: { type: 'String', desc: 'serialized array of scopes' }
      expose :state, documentation: { type: 'String', desc: 'active/non-active state of key' }
      expose :secret, if: ->(api_key) { api_key.hmac? }, documentation: { type: 'String' }

      with_options(format_with: :iso_timestamp) do
        expose :created_at
        expose :updated_at
      end

      private

      def secret
        secret = SecureRandom.hex(16)
        SecretStorage.store_secret(secret, object.kid)
        secret
      end
    end
  end
end
