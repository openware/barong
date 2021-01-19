# frozen_string_literal: true

module API::V2::Management
  module Entities
    class Phone < API::V2::Entities::Phone
      expose :number,
             documentation: {
              type: 'String',
              desc: 'Phone Number'
             }
    end
  end
end
