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
          present current_user.documents, with: API::V2::Entities::Document
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
          requires :doc_type,
                   type: String,
                   allow_blank: false,
                   desc: 'Document type'
          requires :doc_number,
                   type: String,
                   allow_blank: false,
                   desc: 'Document number'
          requires :uploads,
                   allow_blank: false,
                   type: { value: Array[File], message: 'invalid.upload.type' },
                   desc: 'Array of Rack::Multipart::UploadedFile'
          optional :doc_expire,
                   type: { value: Date, message: 'resource.documents.expire_not_a_date' },
                   allow_blank: false,
                   desc: 'Document expiration date'
          optional :metadata, type: Hash, desc: 'Any key:value pairs'
        end

        post do
          unless params[:uploads].all? { |x| x.is_a? Hash }
            error!({ errors: ['resource.documents.uploads_invalid_type'] }, 422)
          end

          if Barong::App.config.required_docs_expire
            error!({ errors: ['resource.documents.invalid_format'] }, 422) unless /\A\d{4}\-\d{2}\-\d{2}\z/.match?(params[:doc_expire].to_s)

            error!({ errors: ['resource.documents.already_expired'] }, 422) if params[:doc_expire] < DateTime.now.to_date
          end

          unless current_user.documents.sum { |d| d.uploads.count } <= ENV.fetch('DOCUMENTS_LIMIT', 10)
            error!({ errors: ['resource.documents.limit_reached'] }, 400)
          end

          unless current_user.documents.sum { |d| d.uploads.count } + params[:uploads].length <= ENV.fetch('DOCUMENTS_LIMIT', 10)
            error!({ errors: ['resource.documents.limit_will_be_reached'] }, 400)
          end

          declared(params).symbolize_keys.tap do |parameter|
            parameter[:uploads].map! do |file|
              {
                io: file['tempfile'],
                filename: file['filename'],
                content_type: file['type']
              }
            end
            doc = current_user.documents.new parameter
            code_error!(doc.errors.details, 400) unless doc.save
          end

          status 201
        end
      end
    end
  end
end
