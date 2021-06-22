# frozen_string_literal: true

module API::V2
  module Resource
    # Addresses API
    class Addresses < Grape::API
      desc 'Documents related routes'
      resource :addresses do
        desc 'Upload a new address approval document for current user',
          success: { code: 201, message: 'New address approval document was uploaded' },
          failure: [
            { code: 400, message: 'Required params are empty' },
            { code: 401, message: 'Invalid bearer token' },
            { code: 422, message: 'Validation errors' }
          ]
        params do
          requires :country,
                   type: String,
                   allow_blank: false,
                   desc: 'Document type'
          requires :address,
                   type: String,
                   allow_blank: false,
                   desc: 'Document number'
          requires :upload,
                   desc: 'Array of Rack::Multipart::UploadedFile'
          requires :city,
                   allow_blank: true,
                   desc: 'Document expiration date'
          requires :postcode, type: String, desc: 'Any additional key: value pairs in json string format'
        end

        post do
          identificator = SecureRandom.hex(16)

          params[:upload].each do |file|
            doc = current_user.documents.new(upload: file, identificator: identificator, doc_type: 'Address')

            code_error!(doc.errors.details, 422) unless doc.save
          end

          KycService.address_step(
            {
              identificator: identificator,
              user_id: current_user.id,
              country: params[:country],
              city: params[:city],
              postcode: params[:postcode],
              address:  params[:address]
            }
          )

          status 201

        rescue Excon::Error => e
          Rails.logger.error e
          error!('Connection error', 422)
        end
      end
    end
  end
end
