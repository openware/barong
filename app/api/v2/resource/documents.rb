# frozen_string_literal: true

module API::V2
  module Resource
    # Dpcuments API
    class Documents < Grape::API
      desc 'Documents related routes'
      resource :documents do
        desc 'Return current user documents list',
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ],
          success: Entities::Document
        get do
          present current_user.documents, with: Entities::Document, only: %i[upload doc_type doc_number doc_expire]
        end

        desc 'Upload a new document for current user',
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
          requires :upload,
                   desc: 'Array of Rack::Multipart::UploadedFile'
          optional :doc_expire,
                   type: { value: Date, message: "resource.documents.expire_not_a_date" },
                   allow_blank: true,
                   desc: 'Document expiration date'
          optional :doc_category,
                   type: String,
                   values: { value: -> (p){ %w[front_side back_side selfie].include?(p) }, message: 'resource.documents.doc_category' },
                   desc: 'Category of the submitted document - front/back/selfie etc.'
          optional :identificator, type: String, desc: 'Identificator for documents to be supplied together'
          optional :metadata, type: String, desc: 'Any additional key: value pairs in json string format'
        end

        post do
          if Barong::App.config.required_docs_expire
            error!({ errors: ['resource.documents.invalid_format'] }, 422) unless /\A\d{4}\-\d{2}\-\d{2}\z/.match?(params[:doc_expire].to_s)

            error!({ errors: ['resource.documents.already_expired'] }, 422) if params[:doc_expire] < DateTime.now.to_date
          end

          unless current_user.documents.count <= Barong::App.config.doc_num_limit
            error!({ errors: ['resource.documents.limit_reached'] }, 400)
          end

          unless current_user.documents.count + params[:upload].length <= Barong::App.config.doc_num_limit
            error!({ errors: ['resource.documents.limit_will_be_reached'] }, 400)
          end
          params[:identificator] = SecureRandom.hex(16) unless params[:identificator]

          params[:upload].each do |file|
            doc = current_user.documents.new(params.except(:upload).merge(upload: file))
            code_error!(doc.errors.details, 422) unless doc.save
          end

          status 201

        rescue Excon::Error => e
          Rails.logger.error e
          error!('Connection error', 422)
        end
      end
    end
  end
end
