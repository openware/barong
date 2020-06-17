# frozen_string_literal: true

class KycService
  # passport front + selfie OR driver license front and back + selfie IR id card front and back + selfie
  REQUIRED_DOC_AMOUNT = { 'PASSPORT': 2, 'DRIVERS_LICENSE': 3, 'GOVERNMENT_ID': 3 }.freeze

  class << self
    def profile_step(profile)
      user = profile.user
      profile_label = user.labels.find_by(key: :profile)

      if profile_label.nil? # first profile ever
        user.labels.create(key: :profile, value: profile.state, scope: :private)
      else
        profile_label.update(value: profile.state) # re-submitted profile
      end

      return if Barong::App.config.kyc_provider == 'local' ||
        profile.state == 'rejected' || profile.state == 'verified' || profile.state == 'drafted' # not an attempt for verification

      KYC.const_get(Barong::App.config.kyc_provider.capitalize, false)::ApplicantWorker.perform_async(profile.id)
    end

    def document_step(document)
      return if document.doc_type == 'Address'

      user = document.user
      user_document_label = user.labels.find_by(key: :document)

      if user_document_label.nil? # first document ever
        user.labels.create(key: :document, value: :pending, scope: :private)
      else
        user_document_label.update(value: :pending) # re-submitted document
      end

      docs_batch_count = user.documents.where(identificator: document.identificator).count
      return unless Barong::App.config.kyc_provider != 'local' ||
        document.doc_type.in?(['Passport', 'Identity card', 'Driver license']) && REQUIRED_DOC_AMOUNT[document.doc_type] == docs_batch_count

      KYC.const_get(Barong::App.config.kyc_provider.capitalize, false)::DocumentWorker.perform_async(user.id, document.identificator) # docs verification worker
    end

    def address_step(address_params)
      user = User.find(address_params[:user_id])
      user_address_label = user.labels.find_by(key: :address)

      if user_address_label.nil? # first address ever
        user.labels.create(key: :address, value: :pending, scope: :private)
      else
        user_address_label.update(value: :pending) # re-submitted address
      end

      return if Barong::App.config.kyc_provider == 'local'

      KYC.const_get(Barong::App.config.kyc_provider.capitalize, false)::AddressWorker.perform_async(address_params.merge(user_id: user.id, identificator: address_params[:identificator]))
    end

    def kycaid_callback(params)
      return 422 if Barong::App.config.kyc_provider == 'local'

      KYC.const_get(Barong::App.config.kyc_provider.capitalize, false)::VerificationsWorker.perform_async(params) # verification worker
      200
    end
  end
end
