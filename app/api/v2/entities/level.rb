# frozen_string_literal: true

module API
  module V2
    module Entities
      class Level < API::V2::Entities::Base
        expose :id,
               documentation: {
                type: 'Integer',
                desc: 'Level identifier, level number'
               }

        expose :key,
               documentation: {
                type: 'String',
                desc: 'Label key. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters.'
               }

        expose :value,
               documentation: {
                type: 'String',
                desc: 'Label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters.'
               }
      end
    end
  end
end
