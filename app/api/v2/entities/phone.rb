# frozen_string_literal: true

module API
  module V2
    module Entities
      # Phone request response
      class Phone < API::V2::Entities::Base
        expose :country, documentation: { type: 'String' }
        expose :number, documentation: { type: 'String', desc: 'Submasker phone number' } do |phone|
          phone.sub_masked_number
        end
        expose :validated_at, documentation: { type: 'Datetime' }
      end
    end
  end
end
