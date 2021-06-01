# frozen_string_literal: true

module API::V2::Commercial
  module Entities
    class OrganizationWithFullInfo < API::V2::Entities::Organization
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
