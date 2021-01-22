# frozen_string_literal: true

module API::V2
  module Entities
    class Job < API::V2::Entities::Base
      expose :id,
      documentation: {
        type: 'Integer',
        desc: 'Job id'
      }

      expose :type,
             documentation: {
               type: 'String',
               desc: 'Job types: maintenance'
             }

      expose :description,
             documentation: {
               type: 'String',
               desc: 'Job description'
             }

      expose :state,
             documentation: {
               type: 'String',
               desc: 'Job states: pending, active, disabled'
             }

      expose :start_at,
             documentation: {
               type: 'DateTime',
               desc: 'Job start date and time'
             }

      expose :finish_at,
             documentation: {
               type: 'DateTime',
               desc: 'Job finish date and time'
             }

      with_options(format_with: :iso_timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end
