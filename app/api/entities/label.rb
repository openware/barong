# frozen_string_literal: true

module Entities
  class Label < Grape::Entity
    format_with(:iso_timestamp) { |d| d.utc.iso8601 }

    expose :key, documentation: { type: 'String', desc: 'Label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters.' }
    expose :value, documentation: { type: 'String', desc: 'Label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters.' }
    expose :scope, documentation: { type: 'String', desc: "Label scope: 'public' or 'private'" }

    with_options(format_with: :iso_timestamp) do
      expose :created_at
      expose :updated_at
    end
  end
end
