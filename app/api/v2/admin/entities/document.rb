# frozen_string_literal: true

module API::V2
  module Admin
    module Entities
      class Document < API::V2::Entities::Document
        expose :doc_number, documentation: { type: 'String', desc: 'document number: AB123123 type' }
        expose :identificator, documentation: { type: 'String', desc: 'document identificator: 16511032654 type' }
      end
    end
  end
end
