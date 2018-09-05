# frozen_string_literal: true

module Entities
  class AccountInfo < Grape::Entity
    format_with(:iso_timestamp) { |d| d.utc.iso8601 }

    expose :email, documentation: { type: 'String' }
    expose :uid, documentation: { type: 'String' }
    expose :role, documentation: { type: 'String' }
    expose :level, documentation: { type: 'Integer' }
    expose :state, documentation: { type: 'String' }

  end
end
