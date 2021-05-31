# frozen_string_literal: true

module API::V2::Organization
  module Entities
    class Profile < API::V2::Entities::Base
      expose :first_name,
             documentation: {
               type: 'String',
               desc: 'Last name'
             }

      expose :last_name,
             documentation: {
               type: 'String',
               desc: 'Last name'
             }
    end
  end
end
