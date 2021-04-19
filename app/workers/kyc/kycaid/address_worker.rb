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
        elsif address.address_id
          @document.update(metadata: { address_id: address.address_id }.to_json)
          verification = ::KYCAID::Verification.create(verification_params)

          if verification.error || verification.errors
            Rails.logger.info("Error in verification creation for: #{@user.uid}: #{verification.error} #{verification.errors}")
            @user.labels.find_by(key: :address, scope: :private).update(value: 'rejected')
          end

          Rails.logger.info("Verification for user address with uid: #{@user.uid}, kycaid id of verification: #{verification.verification_id}")
        end
      rescue OpenURI::HTTPError => e
        Rails.logger.info("#{self.class} caught #{e.inspect()}, retrying in 30 seconds")
        self.class.perform_in(30.seconds, params)
      end

      def address_params
        {
          front_file: {
            tempfile: URI.open(@document.upload.url),
            file_extension: @document.upload.file.extension,
            file_name: @document.upload.file.filename,
          },
          type: 'REGISTERED',
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
          form_id: Barong::App.config.kycaid_form_id,
          callback_url: "#{Barong::App.config.domain}/api/v2/barong/public/kyc"
        }.delete_if { |key, value| value.blank? }
      end
    end
  end
end
