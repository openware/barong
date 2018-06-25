# frozen_string_literal: true

module Entities
  class DeviceActivity < Grape::Entity
    format_with(:iso_timestamp) { |d| d.utc.iso8601 }

    expose :user_ip, documentation: { type: 'String' }
    expose :user_os, documentation: { type: 'String' }
    expose :country, documentation: { type: 'String' }
    expose :action, documentation: { type: 'String' }
    expose :status, documentation: { type: 'String' }

    with_options(format_with: :iso_timestamp) do
      expose :created_at
    end
  end
end
