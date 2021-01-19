# frozen_string_literal: true

module API::V2
  module Entities
    class ServiceAccounts < API::V2::Entities::Base
      expose :email,
             documentation: {
              type: 'String',
              desc: 'User Email'
             }

      expose :uid,
             documentation: {
              type: 'String',
              desc: 'User UID'
             }

      expose :role,
             documentation: {
              type: 'String',
              desc: 'Service Account Role'
             }

      expose :level,
             documentation: {
              type: 'Integer',
              desc: 'User Level'
             }

      expose :state,
             documentation: {
              type: 'String',
              desc: 'Service Account State: active, disabled'
             }

      expose :user, using: Entities::User

      with_options(format_with: :iso_timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end
