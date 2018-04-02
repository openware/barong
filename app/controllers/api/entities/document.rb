module API
  module Entities
    class Document < Grape::Entity
      expose :upload
      expose :doc_type, as: :type, override: true
      expose :doc_number, as: :number, override: true
      expose :doc_expire, as: :expire_date, override: true
    end
  end
end
