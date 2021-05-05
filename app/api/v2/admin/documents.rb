# frozen_string_literal: true
module API
  module V2
    module Admin
      # Admin functionality over users table
      class Documents < Grape::API
        resource :documents do
          params do
            requires :document_id,
                     type: Integer,
                     desc: 'document id'
          end
          get "/:document_id" do
            admin_authorize! :read, Document

            document = Document.find_by_id(params[:document_id])
            error!({ errors: ['admin.document.doesnt_exist'] }, 404) if document.nil?
            redirect document.upload_url
          end
        end
      end
    end
  end
end

