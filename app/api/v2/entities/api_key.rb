# frozen_string_literal: true

module API::V2
  module Entities
    class APIKey < API::V2::Entities::Base
      expose :kid, documentation: { type: 'String', desc: 'jwt public key' }
      expose :algorithm, documentation: { type: 'String', desc: 'cryptographic hash function type' }
      expose :scope, documentation: { type: 'String', desc: 'serialized array of scopes' }
      expose :state, documentation: { type: 'String', desc: 'active/non-active state of key' }
      expose :secret, if: ->(api_key) { api_key.hmac? }, documentation: { type: 'String' }

      with_options(format_with: :iso_timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end
