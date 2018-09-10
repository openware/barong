# frozen_string_literal: true

module Entities
  class APIKey < Grape::Entity
    format_with(:iso_timestamp) { |d| d.utc.iso8601 }

    expose :uid, documentation: { type: 'String' }
    expose :public_key, documentation: { type: 'String' }
    expose :scopes, documentation: { type: 'Array', desc: 'array of scopes' }
    expose :expires_in, documentation: { type: 'String', desc: 'expires_in duration in seconds. Min 30 seconds, Max 86400 seconds' }
    expose :state, documentation: { type: 'String' }

    with_options(format_with: :iso_timestamp) do
      expose :created_at
      expose :updated_at
    end
  end
end
