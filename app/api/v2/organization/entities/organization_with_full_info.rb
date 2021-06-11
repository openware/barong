# frozen_string_literal: true

module API::V2::Organization
  module Entities
    class OrganizationWithFullInfo < API::V2::Entities::Base
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

      expose :email,
             documentation: {
               type: 'String',
               desc: 'Organization Conntact Email'
             }

      expose :country,
             documentation: {
               type: 'String',
               desc: 'Organization Country'
             }

      expose :group,
             documentation: {
               type: 'String',
               desc: 'Organization Fee Group'
             }

      expose :city,
             documentation: {
               type: 'String',
               desc: 'Organization City'
             }

      expose :phone,
             documentation: {
               type: 'String',
               desc: 'Organization Contact Number'
             }

      expose :address,
             documentation: {
               type: 'String',
               desc: 'Organization Contact Number'
             }

      expose :postcode,
             documentation: {
               type: 'String',
               desc: 'Organization Postcode'
             }
    end
  end
end
