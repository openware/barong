# frozen_string_literal: true

module API::V2
  module Entities
    class PublicAddress < API::V2::Entities::Base
      expose :uid,
             documentation: {
              type: 'String',
              desc: 'Public Address UID'
             }

      expose :address,
             documentation: {
              type: 'String',
              desc: 'Public Address'
             }

      expose :role,
             documentation: {
              type: 'String',
              desc: 'Public Address Role'
             }

      expose :level,
             documentation: {
              type: 'Integer',
              desc: 'Public Address Level'
             }

      expose :state,
             documentation: {
              type: 'String',
              desc: 'Public Address State: active, disabled'
             }

      with_options(format_with: :iso_timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end
