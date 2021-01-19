# frozen_string_literal: true

module API::V2::Admin
  module Entities
    class Phone < API::V2::Entities::Phone
      expose :number,
             documentation: {
              type: 'String',
              desc: 'Phone number'
             }
    end
  end
end
