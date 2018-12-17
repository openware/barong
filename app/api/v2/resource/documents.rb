# frozen_string_literal: true

module API::V2
  module Resource
    # Dpcuments API
    class Documents < Grape::API
      desc 'Documents related routes'
      resource :documents do
        desc 'Return current user documents list',
             security: [{ 'BearerToken': [] }],
             failure: [
               { code: 401, message: 'Invalid bearer token' }
             ]
        get do
          current_user.documents.as_json(only: %i[upload doc_type doc_number doc_expire])
        end

        desc 'Upload a new document for current user',
             security: [{ 'BearerToken': [] }],
             success: { code: 201, message: 'Document is uploaded' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :doc_expire, type: Date, allow_blank: false, desc: 'Document expiration date'
          requires :doc_type, type: String, allow_blank: false, desc: 'Document type'
          requires :doc_number, type: String, allow_blank: false, desc: 'Document number'
          requires :attachments, type: Array do
            requires :upload, type: Rack::Multipart::UploadedFile, desc: 'Uploaded files'
          end
          optional :metadata, type: Hash, desc: 'Any key:value pairs'
        end

        post do
          unless current_user.documents.count < ENV.fetch('DOCUMENTS_LIMIT', 10)
            error! 'Maximum number of documents was reached', 400
          end

          unless params[:attachments].length < ENV.fetch('DOCUMENTS_LIMIT', 10)
            error! 'Too many documents uploaded at once', 400
          end

          params[:attachments].each do |upload|
            doc = current_user.documents.new(declared(params).except(:attachments).merge(upload))

            error!(doc.errors.full_messages.to_sentence, 400) unless doc.save

            status 201
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
