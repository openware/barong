# frozen_string_literal: true

class KycService
  # passport front + selfie OR driver license front and back + selfie IR id card front and back + selfie
  REQUIRED_DOC_AMOUNT = { 'Passport': 2, 'Driver license': 3, 'Identity card': 3 }.freeze

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

      docs_batch_count = user.documents.where(identificator: document.identificator).count
      if Barong::App.config.kyc_provider == 'local'
        document_label_update(user)
        return
      end
      return unless document.doc_type.in?(['Passport', 'Identity card', 'Driver license'])
      return if REQUIRED_DOC_AMOUNT[document.doc_type.to_sym] != docs_batch_count

      document_label_update(user)

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

    def document_label_update(user)
      user_document_label = user.labels.find_by(key: :document)
      if user_document_label.nil? # first document ever
        user.labels.create(key: :document, value: :pending, scope: :private)
      else
        user_document_label.update(value: :pending) # re-submitted document
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "#{e.message}\n#{e.backtrace[0..5].join("\n")}"
    end
  end
end
