require 'sidekiq'

module KYC
  module Kycaid
    class AddressWorker
      include Sidekiq::Worker

      def perform(params = {})
        @params = params.symbolize_keys
        
        @user = User.find(@params[:user_id])
        @applicant_id = @user.profiles.last.applicant_id
        @document = Document.find_by(identificator: @params[:identificator])
        address = ::KYCAID::Address.create(address_params)

        if address.error || address.errors
          Rails.logger.info("Error in document creation for: #{@user.uid}: #{address.errors} #{address.error}")
          @user.labels.find_by(key: :address, scope: :private).update(value: 'rejected')
        elsif address.document_id
          @document.update(metadata: { address_id: address.document_id }.to_json)
          verification = ::KYCAID::Verification.create(verification_params)
        end
      end

      def address_params
        {
          front_file: {
            tempfile: URI.open(@document.upload.url),
            file_extension: @document.upload.file.extension,
            file_name: @document.upload.file.filename,
          },
          type: 'ADDRESS_DOCUMENT',
          applicant_id: @applicant_id,
          country: @params[:country],
          city: @params[:city],
          postal_code: @params[:postcode],
          full_address: @params[:address],
        }.compact
      end

      def verification_params
        {
          applicant_id: @applicant_id,
          types: ['ADDRESS'],
          callback_url: "#{Barong::App.config.domain}/api/v2/barong/public/kyc"
        }
      end
    end
  end
end
