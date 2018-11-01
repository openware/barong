# frozen_string_literal: true

module Entities
  class APIKey < Grape::Entity
    format_with(:iso_timestamp) { |d| d.utc.iso8601 }

    expose :uid, documentation: { type: 'String' }
    expose :kid, documentation: { type: 'String' }
    expose :algorithm, documentation: { type: 'String', desc: 'type of secure hash algorithm' }
    expose :scopes, documentation: { type: 'Array', desc: 'array of scopes' }
    expose :state, documentation: { type: 'String' }
    expose :secret, if: -> (api_key){ api_key.hmac? }

    with_options(format_with: :iso_timestamp) do
      expose :created_at
      expose :updated_at
    end

    private

    def secret
      secret = SecureRandom.hex(16)
      Vault::APISecretsStorage.store_secret(secret, object.kid)
      return secret
    end
  end
end
