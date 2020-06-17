require 'sidekiq'

module KYC
  module Kycaid
    class DocumentWorker
      include Sidekiq::Worker
      KYCAID_DOC_TYPES = { "Passport" => 'PASSPORT', 'Identity card' => 'GOVERNMENT_ID', 'Driver license' => 'DRIVERS_LICENSE' }.freeze

      def perform(user_id, identificator)
        # user, that will be verified
        @user = User.find(user_id)
        # exact batch of the docs to be verified
        docs = @user.documents.where(identificator: identificator)
        # user should already have applicant on his last profile to be able to proceed documents verification
        @applicant_id = @user.profiles.last.applicant_id

        # creates a KYCAID::File for front/back and KYCAID::Document with linking files
        front_file = docs.find_by(doc_category: 'front_side')
        back_file = docs.find_by(doc_category: 'back_side')
        selfie_file = docs.find_by(doc_category: 'selfie')

        document = ::KYCAID::Document.create(document_params(front_file, back_file))
        selfie_document = ::KYCAID::Document.create(selfie_image_params(selfie_file))

        if document.error || document.errors || selfie_document.error || selfie_document.errors
          Rails.logger.info("Error in document creation for: #{@user.uid}: #{document.error} #{document.errors} \
                             or in  selfie image creation for: #{@user.uid}: #{selfie_document.error} #{selfie_document.errors}")
          @user.labels.find_by(key: :document, scope: :private).update(value: 'rejected')
        elsif document.document_id && selfie_document.document_id
          docs.update_all(metadata: { document_id: @document_id }.to_json)
          verification = ::KYCAID::Verification.create(verification_params)

          Rails.logger.info("Verification for user: #{@user.uid} kycaid id of verification: #{verification.verification_id}")
        end
      end

      def document_params(front_file, back_file)
        {
          front_file: {
            tempfile: URI.open(front_file.upload.url),
            file_extension: front_file.upload.file.extension,
            file_name: front_file.upload.file.filename,
          },
          back_file: ({
            tempfile: URI.open(back_file.upload.url),
            file_extension: back_file.upload.file.extension,
            file_name: back_file.upload.file.filename,
          } if back_file),
          expiry_date: front_file.doc_expire,
          document_number: front_file.doc_number,
          type: KYCAID_DOC_TYPES[front_file.doc_type],
          applicant_id: @applicant_id
        }.compact
      end

      def selfie_image_params(selfie_image)
        {
          front_file: {
            tempfile: URI.open(selfie_image.upload.url),
            file_extension: selfie_image.upload.file.extension,
            file_name: selfie_image.upload.file.filename,
          },
          type: 'SELFIE_IMAGE',
          applicant_id: @applicant_id
        }
      end

      def verification_params
        {
          applicant_id: @applicant_id,
          types: ['DOCUMENT', 'FACIAL'],
          callback_url: "#{Barong::App.config.domain}/api/v2/barong/public/kyc"
        }
      end
    end
  end
end
