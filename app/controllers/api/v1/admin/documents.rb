# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    module Admin
      class Documents < Grape::API
        desc 'Documents related routes'
        resource :documents do
          desc 'Return documents of specific Account'
          get '/profile_documents' do
            authorize! :read, Document
            Profile.find_by_id(params[:id]).documents.as_json(only: %i[upload doc_type doc_number doc_expire])
          end
        end
      end
    end
  end
end
