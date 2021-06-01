# frozen_string_literal: true

module API
  module V2
    module Entities
      class Organization < API::V2::Entities::Base
        expose :id,
               documentation: {
                 type: 'Integer',
                 desc: 'Organization ID'
               }

        expose :oid,
               documentation: {
                 type: 'String',
                 desc: 'Organization OID'
               }

        expose :name,
               documentation: {
                 type: 'String',
                 desc: 'Organization Account Name'
               }

        expose :status,
               documentation: {
                 type: 'String',
                 desc: 'Organization Account Status'
               }
      end
    end
  end
end
