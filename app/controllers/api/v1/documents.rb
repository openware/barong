# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    class Documents < Grape::API
      format :json

      desc 'Creates new document'
      resource :document do
        params do
          requires :uid,        type: String, desc: 'UID of account'
          requires :upload,     type: File,   desc: 'Document upload'
          requires :doc_type,   type: String, desc: 'Type of document'
          requires :doc_number, type: String, desc: 'Number of document'
          requires :doc_expire, type: String, desc: 'Expiry date of document'
        end
        post '/create' do
          document = Document.create(profile_id: Account.find_by_uid(params[:uid]).profile.id,
                                     upload:     params[:upload],
                                     doc_type:   params[:doc_type],
                                     doc_number: params[:doc_number],
                                     doc_expire: params[:doc_expire])
          document.save
        end
      end
    end
  end
end
