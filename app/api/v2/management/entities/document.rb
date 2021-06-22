# frozen_string_literal: true

module API::V2::Management
  module Entities
    class Document < API::V2::Entities::Document
      expose :doc_number,
             documentation: {
               type: 'String', desc: 'Document number: AB123123 type'
             }
    end
  end
end
