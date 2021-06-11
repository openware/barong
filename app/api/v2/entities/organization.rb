# frozen_string_literal: true

module API
  module V2
    module Entities
      class Organization < API::V2::Entities::Base
        expose :id,
               documentation: {
                 type: 'Integer',
                 desc: 'Organization ID'
               } do |org|
          if org.parent_organization.present?
            org.parent_organization
          else
            org.id
          end
        end

        expose :oid,
               documentation: {
                 type: 'String',
                 desc: 'Organization OID'
               } do |org|
          if org.parent_organization.present?
            ::Organization.find(org.parent_organization).oid
          else
            org.oid
          end
        end

        expose :name,
               documentation: {
                 type: 'String',
                 desc: 'Organization Account Name'
               } do |org|
          if org.parent_organization.present?
            ::Organization.find(org.parent_organization).name
          else
            org.name
          end
        end

        expose :status,
               documentation: {
                 type: 'String',
                 desc: 'Organization Account Status'
               } do |org|
          if org.parent_organization.present?
            ::Organization.find(org.parent_organization).status
          else
            org.status
          end
        end

        expose :subunit, using: Entities::Subunit do |org|
          if org.parent_organization.nil?
            nil
          else
            org
          end
        end
      end
    end
  end
end
