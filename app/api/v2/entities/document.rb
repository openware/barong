# frozen_string_literal: true

module API
  module V2
    module Entities
      # Return user document with related info
      class Document < Grape::Entity
        include Rails.application.routes.url_helpers

        format_with(:iso_timestamp) { |d| d.utc.iso8601 }

        expose(
          :uploads,
          documentation: {
            type: 'Array',
            desc: 'Array of file urls'
          }
        ) do |doc, _options|
            doc.uploads.map { |upload| rails_blob_url(upload, only_path: true) }
        end

        expose :doc_type, documentation: { type: 'String', desc: 'document type: passport, driver license' }
        expose :doc_number, documentation: { type: 'String', desc: 'document number: AB123123 type' }
        expose :doc_expire, documentation: { type: 'String', desc: 'expire date of uploaded documents' }
        expose :metadata, documentation: { type: 'String', desc: 'any additional stored data' }

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end
      end
    end
  end
end
