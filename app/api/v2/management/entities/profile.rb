# frozen_string_literal: true

module API::V2::Management
  module Entities
    class Profile < API::V2::Entities::Profile
      expose :last_name,
             documentation: {
              type: 'String',
              desc: 'Last name'
             }

      expose :dob,
             documentation: {
              type: 'Date',
              desc: 'Birth date'
             }
    end
  end
end
