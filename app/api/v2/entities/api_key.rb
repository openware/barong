# frozen_string_literal: true

module API::V2
  module Entities
    class APIKey < Grape::Entity
      format_with(:iso_timestamp) { |d| d.utc.iso8601 }

      expose :kid, documentation: { type: 'String' }
      expose :algorithm, documentation: { type: 'String' }
      expose :scope, documentation: { type: 'Array', desc: 'array of scopes' }
      expose :state, documentation: { type: 'String' }
      expose :secret, if: -> (api_key){ api_key.hmac? }

      with_options(format_with: :iso_timestamp) do
        expose :created_at
        expose :updated_at
      end

      private

      def secret
        secret = SecureRandom.hex(16)
        SecretStorage.store_secret(secret, object.kid)
        return secret
      end

    end
  end
end
