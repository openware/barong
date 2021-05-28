# frozen_string_literal: true

module API::V2::Commercial
  module Entities
    class Organization < API::V2::Entities::Organization
      expose :email,
             documentation: {
               type: 'String',
               desc: 'Organization Contact Email'
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

      expose :created_at,
             documentation: {
               type: 'String',
               desc: 'Organization Created Date'
             }

      expose :subunits do |org|
        org.organizations.length
      end
    end
  end
end
