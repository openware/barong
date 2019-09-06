# frozen_string_literal: true

module API
  module V2
    module Entities
      # Phone request response
      class Phone < Base
        expose :country, documentation: { type: 'String' }
        expose :number, documentation: { type: 'String' }
        expose :validated_at, documentation: { type: 'Datetime' }
      end
    end
  end
end
