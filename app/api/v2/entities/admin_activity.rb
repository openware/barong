# frozen_string_literal: true

module API::V2
  module Entities
    class AdminActivity < Grape::Entity
      format_with(:iso_timestamp) { |d| d.utc.iso8601 }

      expose :user_ip, documentation: { type: 'String' }
      expose :user_agent, documentation: { type: 'String' }
      expose :topic, documentation: { type: 'String' }
      expose :action, documentation: { type: 'String' }
      expose :result, documentation: { type: 'String' }
      expose :data, documentation: { type: 'String' }
      expose :user, as: :admin, using: Entities::User
      expose :target, as: :target, using: Entities::User

      with_options(format_with: :iso_timestamp) do
        expose :created_at
      end
    end
  end
end
