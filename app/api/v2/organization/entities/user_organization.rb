# frozen_string_literal: true

module API::V2::Organization
  module Entities
    class UserOrganization < API::V2::Entities::Base
      expose :parent_oid do |member|
        if member.organization.parent_organization.nil?
          member.organization.oid
        else
          org = ::Organization.find(member.organization.parent_organization)
          org.oid
        end
      end

      expose :organization do |member|
        if member.organization.parent_organization.nil?
          member.organization.name
        else
          org = ::Organization.find(member.organization.parent_organization)
          org.name
        end
      end

      expose :oid do |member|
        if member.organization.parent_organization.nil?
          nil
        else
          member.organization.oid
        end
      end

      expose :subunit do |member|
        if member.organization.parent_organization.nil?
          nil
        else
          member.organization.name
        end
      end

      expose :role do |member|
        member.role
      end
    end
  end
end
