# frozen_string_literal: true

module Entities
  class Device < Grape::Entity
    format_with(:iso_timestamp) { |d| d.utc.iso8601 }

    expose :action, documentation: { type: 'String' }
    expose :result, documentation: { type: 'String' }
    expose :uuid, documentation: { type: 'String' }
    expose :ip, documentation: { type: 'String' }
    expose :os, documentation: { type: 'String' }
    expose :user_agent, documentation: { type: 'String' }
    expose :browser, documentation: { type: 'String' }
    expose :otp, documentation: { type: 'String' }
    expose :country, documentation: { type: 'String' }
    expose :expire_at, documentation: { type: 'String' }

    with_options(format_with: :iso_timestamp) do
      expose :created_at
    end
  end
end
