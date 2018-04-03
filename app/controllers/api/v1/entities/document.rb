# frozen_string_literal: true

module API::V1::Entities
  class Document < Grape::Entity
    expose :upload,                                       documentation: { desc: 'Document upload, expected extensions jpg, jpeg, png' }
    expose :doc_type, as: :type, override: true,          documentation: { desc: 'Document type (passport, identity card, driver license)' }
    expose :doc_number, as: :number, override: true,      documentation: { desc: 'Document unique number' }
    expose :doc_expire, as: :expire_date, override: true, documentation: { desc: 'Expiry date of the document' }
  end
end
