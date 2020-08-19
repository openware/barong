# frozen_string_literal: true

module API::V2
  module Entities
    class ServiceAccounts < API::V2::Entities::Base
      expose :email, documentation: { type: 'String' }
      expose :uid, documentation: { type: 'String' }
      expose :role, documentation: { type: 'String' }
      expose :level, documentation: { type: 'Integer' }
      expose :state, documentation: { type: 'String' }
      expose :user, using: Entities::User

      with_options(format_with: :iso_timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end
