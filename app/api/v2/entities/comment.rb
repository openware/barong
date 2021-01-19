# frozen_string_literal: true

module API
  module V2
    module Entities
      # comment retrieval entity
      class Comment < API::V2::Entities::Base
        expose :id,
               documentation: {
                type: 'Integer',
                desc: 'Comment id'
               }

        expose :author_uid,
               documentation: {
                type: 'String',
                desc: 'Comment author UID'
               }

        expose :title,
               documentation: {
                type: 'String',
                desc: 'Comment title'
               }

        expose :data,
               documentation: {
                type: 'String',
                desc: 'Comment plain text'
               }

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end
      end
    end
  end
end
