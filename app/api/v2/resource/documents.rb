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
          requires :doc_expire,
                   type: Date,
                   allow_blank: false,
                   desc: 'Document expiration date'
          requires :doc_type,
                   type: String,
                   allow_blank: false,
                   desc: 'Document type'
          requires :doc_number,
                   type: String,
                   allow_blank: false,
                   desc: 'Document number'
          requires :upload,
                   desc: 'Array of Rack::Multipart::UploadedFile'
          optional :metadata, type: Hash, desc: 'Any key:value pairs'
        end

        post do
          unless current_user.documents.count <= ENV.fetch('DOCUMENTS_LIMIT', 10)
            error!({ errors: ['resource.documents.limit_reached'] }, 400)
          end

          unless current_user.documents.count + params[:upload].length <= ENV.fetch('DOCUMENTS_LIMIT', 10)
            error!({ errors: ['resource.documents.limit_will_be_reached'] }, 400)
          end

          params[:upload].each do |file|
            doc = current_user.documents.new(declared(params).except(:upload).merge(upload: file))

            code_error!(doc.errors.details, 400) unless doc.save
          end
          status 201

        rescue Excon::Error => e
          error!('Connection error', 500)
          logger.fatal(e)
        end
      end
    end
  end
end
