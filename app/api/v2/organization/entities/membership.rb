# frozen_string_literal: true

module API::V2::Organization
  module Entities
    class Membership < API::V2::Entities::Base
      expose :id,
             documentation: {
               type: 'Integer',
               desc: 'Membership Id'
             }

      expose :uid do |member|
        member.user.uid
      end

      expose :profiles, using: Entities::Profile do |member|
        member.user.profiles
      end

      expose :role do |member|
        member.role
      end

      expose :subunit do |member|
        if member.organization.parent_organization.nil?
          # return subunit as null for parent organization
          nil
        else
          member.organization.name
        end
      end

      expose :created_at,
             documentation: {
               type: 'String',
               desc: 'Membership Created Date'
             }

      expose :updated_at,
             documentation: {
               type: 'String',
               desc: 'Membership Updated Date'
             }
    end
  end
end
