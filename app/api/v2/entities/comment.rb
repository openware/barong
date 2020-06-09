# frozen_string_literal: true

module API
  module V2
    module Entities
      # comment retrieval entity
      class Comment < API::V2::Entities::Base
        expose :id, documentation: { type: 'Integer', desc: 'comment id' }
        expose :author_uid, documentation: { type: 'String', desc: 'comment author' }
        expose :title, documentation: { type: 'String', desc: 'comment title' }
        expose :data, documentation: { type: 'String', desc: 'comment plain text' }

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end
      end
    end
  end
end
