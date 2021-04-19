# frozen_string_literal: true

module API::V2::Commercial
  module Entities
    class AccountBase < API::V2::Entities::Base
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
    end

    class Account < AccountBase
      expose :uids do |member|
        member.memberships.map { |m| m.user.uid }
      end
    end

    class OrganizationAccount < AccountBase
      expose :users do |member|
        member.memberships.length
      end
    end
  end
end
