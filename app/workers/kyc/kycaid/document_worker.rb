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
        # exact batch of the docs which have already been loaded to KYCaid
        docs_with_metadata = @user.documents.where.not(metadata: nil)
        # user should already have applicant on his last profile to be able to proceed documents verification
        @applicant_id = @user.profiles.last.applicant_id
        # creates a KYCAID::File for front/back and KYCAID::Document with linking files
        front_file = docs.find_by(doc_category: 'front_side')
        back_file = docs.find_by(doc_category: 'back_side')
        selfie_file = docs.find_by(doc_category: 'selfie')

        # If there is document ID in selfie/back_side/front_side doc category files
        # system will get the last one and check metadata document id to do update of old one
        old_selfie_document = docs_with_metadata.where(doc_category: 'selfie').last
        old_document = docs_with_metadata.where('doc_category = ? OR doc_category = ?', 'front_side', 'back_side').last
        selfie_document = create_or_update_selfie_doc(old_selfie_document, selfie_file)
        document = create_or_update_doc(old_document, front_file, back_file)

        if document.document_id && selfie_document.document_id
          front_file&.update(metadata: { document_id: document.document_id }.to_json)
          back_file&.update(metadata: { document_id: document.document_id }.to_json)
          selfie_file&.update(metadata: { document_id: selfie_document.document_id }.to_json)
          verification = ::KYCAID::Verification.create(verification_params)

          if verification.error || verification.errors
            Rails.logger.info("Error in verification creation for: #{@user.uid}: #{verification.error} #{verification.errors}")
            @user.labels.find_by(key: :document, scope: :private).update(value: 'rejected')
          end

          Rails.logger.info("Verification for user document with uid: #{@user.uid}, kycaid id of verification: #{verification.verification_id}")
        elsif document.document_id
          # If there is document id for document it means system has problems with selfie document upload
          Rails.logger.info("Error in selfie image creation for: #{@user.uid}: #{selfie_document.error} #{selfie_document.errors}")

          front_file&.update(metadata: { document_id: document.document_id }.to_json)
          back_file&.update(metadata: { document_id: document.document_id }.to_json)
          @user.labels.find_by(key: :document, scope: :private).update(value: 'rejected')
        elsif selfie_document.document_id
          # If there is document id for selfie_document it means system has problems with front_side/back_side document upload
          Rails.logger.info("Error in document image creation creation for: #{@user.uid}: #{document.error} #{document.errors}")

          selfie_file&.update(metadata: { document_id: selfie_document.document_id }.to_json)
          @user.labels.find_by(key: :document, scope: :private).update(value: 'rejected')
        elsif (document.error || document.errors) && (selfie_document.error || selfie_document.errors)
          Rails.logger.info("Error in document creation for: #{@user.uid}: #{document.error} #{document.errors} \
          and in  selfie image creation for: #{@user.uid}: #{selfie_document.error} #{selfie_document.errors}")

          @user.labels.find_by(key: :document, scope: :private).update(value: 'rejected')
        end
      rescue OpenURI::HTTPError => e
        Rails.logger.info("#{self.class} caught #{e.inspect()}, retrying in 30 seconds")
        self.class.perform_in(30.seconds, user_id, identificator)
      end

      def create_or_update_selfie_doc(old_selfie_document, new_selfie_document)
        if old_selfie_document
          document_id = JSON.parse(old_selfie_document.metadata)['document_id']
          params = selfie_image_params(new_selfie_document).merge(id: document_id)
          Rails.logger.info { "Updating selfie document with params #{params}"}
          ::KYCAID::Document.update(params)
        else
          Rails.logger.info { "Creating selfie document with params #{params}"}
          ::KYCAID::Document.create(selfie_image_params(new_selfie_document))
        end
      end

      def create_or_update_doc(old_document, front_file, back_file)
        if old_document
          document_id = JSON.parse(old_document.metadata)['document_id']
          params = document_params(front_file, back_file).merge(id: document_id)
          Rails.logger.info { "Updating front_side/back_side document with params #{params}"}
          ::KYCAID::Document.update(params)
        else
          Rails.logger.info { "Creating front_side/back_side document with params #{params}"}
          ::KYCAID::Document.create(document_params(front_file, back_file))
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
          form_id: Barong::App.config.kycaid_form_id,
          callback_url: "#{Barong::App.config.domain}/api/v2/barong/public/kyc"
        }.delete_if { |key, value| value.blank? }
      end
    end
  end
end
