# frozen_string_literal: true

module API
  module V1
    module Entities
      class Document < Grape::Entity
        expose :upload,     documentation: { type: 'File',   desc: 'Document upload' }
        expose :doc_type,   documentation: { type: 'String', desc: 'Type of document' }
        expose :doc_number, documentation: { type: 'String', desc: 'Number of document' }
        expose :doc_expire, documentation: { type: 'String', desc: 'Expiry date of document' }
      end
    end
  end
end
