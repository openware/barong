# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    class Documents < Grape::API
      format :json

      helpers Doorkeeper::Grape::Helpers

      before do
        def document
          @document = Account.find_by_uid(params[:uid]).profile.documents
        end
      end

      desc 'Documents related routes'
      resource :document do
        desc 'Return information about document'
        get '/' do
          document.as_json(only: %i[upload doc_type doc_number doc_expire])
        end

        desc 'Creates new document'
        params do
          requires :profile_id, type: String, desc: 'Id of profile'
          requires :upload,     type: File,   desc: 'Document upload'
          requires :doc_type,   type: String, desc: 'Type of document'
          requires :doc_number, type: String, desc: 'Number of document'
          requires :doc_expire, type: String, desc: 'Expiry date of document'
        end
        post '/create' do
          Document.create!(profile_id: params[:profile_id],
                           upload:     params[:upload],
                           doc_type:   params[:doc_type],
                           doc_number: params[:doc_number],
                           doc_expire: params[:doc_expire])
        end
      end
    end
  end
end
