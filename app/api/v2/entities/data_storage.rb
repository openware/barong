# frozen_string_literal: true

module API
  module V2
    module Entities
      # data storage retrieval entity
      class DataStorage < API::V2::Entities::Base
        expose :title,
               documentation: {
                type: 'String',
                desc: 'Any additional data title'
               }

        expose :data,
               documentation: {
                type: 'String',
                desc: 'Any additional data json key:value pairs'
               }

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end
      end
    end
  end
end
