# frozen_string_literal: true

module API::V2::Organization
  module Entities
    class OrganizationAccount < API::V2::Entities::Base
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

      expose :users do |member|
        member.memberships.length
      end
    end
  end
end
