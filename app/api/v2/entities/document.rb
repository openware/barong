# frozen_string_literal: true

module API
  module V2
    module Entities
      # Return user document with related info
      class Document < API::V2::Entities::Base
        expose :upload,
               documentation: {
                type: 'String',
                desc: 'File url'
               }

        expose :doc_type,
               documentation: {
                type: 'String',
                desc: 'Document type: passport, driver license, utility bill, identity card, institutional, address, residental'
               }

        expose :doc_number,
               documentation: {
                type: 'String',
                desc: 'Submasked document number: AB123123 type'
               } do |document|
                Barong::App.config.api_data_masking_enabled ? document.sub_masked_doc_number : document.doc_number
               end

        expose :doc_expire,
               documentation: {
                type: 'String',
                desc: 'Expire date of uploaded documents'
               }

        expose :metadata,
               documentation: {
                type: 'String',
                desc: 'Any additional stored data'
               }

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end
      end
    end
  end
end
