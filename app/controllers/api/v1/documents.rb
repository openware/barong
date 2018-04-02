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

      desc 'Documents related routes'
      resource :documents do
        desc 'Return current user documents list'
        get '/' do
          current_account.documents.as_json(only: %i[upload doc_type doc_number doc_expire])
        end

        desc 'Upload a new document for current user'
        params do
          requires :doc_expire, :doc_type, :doc_number, :upload
        end

        post '/' do
          doc = current_account.documents.new(declared(params))
          if doc.save
            status 201
          else
            error!(doc.errors.full_messages.to_sentence, 400)
          end
        # temporary rescues the connection errors in fog-gooogle
        # TODO: check workability after adding carrierwave-google-storage gem
        rescue Excon::Error => e
          error!('Connection error', 500)
          logger.fatal(e)
        end
      end
    end
  end
end
