# frozen_string_literal: true

module API
  module V2
    module Entities
      class Permission < API::V2::Entities::Base
        expose :id,
               documentation: {
                 type: 'Integer',
                 desc: 'Permission id'
               }

        expose :action,
               documentation: {
                 type: 'String',
                 desc: 'Permission action: accept (allow access (drop access), audit (record activity)'
               }

        expose :role,
               documentation: {
                type: 'String',
                desc: 'Permission user role'
               }

        expose :verb,
               documentation: {
                type: 'String',
                desc: 'Permission verb: put, post, delete, get'
               }

        expose :path,
               documentation: {
                type: 'String',
                desc: 'API path'
              }

        expose :topic,
               documentation: {
                type: 'String',
                desc: 'Permission topic: general, session etc'
               }

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end
      end
    end
  end
end
