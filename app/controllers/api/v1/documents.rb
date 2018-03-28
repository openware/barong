# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    class Documents < Grape::API
      helpers Doorkeeper::Grape::Helpers

      before do
        doorkeeper_authorize!

        def current_account
          Account.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
        end
      end

      desc 'Account related routes'
      resource :documents do
        desc 'Return current user documents list'
        get '/' do
          current_account.profile.documents.as_json(only: %i[upload doc_type doc_number doc_expire])
        end

        desc 'Upload a new document for current user'
        params do
          requires :doc_expire, :doc_type, :doc_number, :upload
        end

        post '/' do
          doc = Document.new(declared(params).merge(profile: current_account.profile))
          return error!(doc.errors.full_messages.to_sentence, 400) unless doc.save
        end
      end
    end
  end
end
