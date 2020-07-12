# frozen_string_literal: true

describe 'KYC::Kycaid::AddressWorker' do
  before { allow(Barong::App.config).to receive_messages(kyc_provider: 'kycaid') }

  include_context 'bearer authentication'
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let(:user) { create(:user) }
  let!(:profile) { create(:profile, country: 'UA', state: 'submitted', applicant_id: '84e51f8a0677a646fd185fc741717ad9a8b3', user_id: user.id) }
  let!(:document) { create(:document, identificator: '84e51f8a06', user_id: user.id, doc_type: 'Address') }
  let!(:label) { create(:label, key: 'address', user_id: user.id, value: 'pending', scope: 'private') }
  let(:address_params) { { "identificator": '84e51f8a06', 'user_id': document.user.id, "country": 'UA', "city": 'Kiev', "postcode": '101010' } }

  describe 'successful verification' do
    let(:successful_docs_response) { OpenStruct.new(address_id: '84e51f8a0677a646fd185fc741717ad9a8b3') }
    let(:successful_verification_response) { OpenStruct.new(verification_id: '84e51f8a0677a646fd185fc741717ad9a8b3') }

    before { allow(KYCAID::Address).to receive(:create).and_return(successful_docs_response) }
    before { allow(KYCAID::Verification).to receive(:create).and_return(successful_verification_response) }

    before { allow_any_instance_of(KYC::Kycaid::AddressWorker).to receive(:address_params).and_return({}) }

    context 'perform' do
      before { allow(KYCAID::Address).to receive(:create).and_return(successful_docs_response) }
      before { allow(KYCAID::Verification).to receive(:create).and_return(successful_verification_response) }

      it 'creates a document record' do
        expect(document.metadata).to eq(nil)
        expect(KYCAID::Address).to receive(:create)

        KYC::Kycaid::AddressWorker.new.perform(address_params)
        expect(document.reload.metadata).not_to eq(nil)
      end

      it 'creates a verification request' do
        expect(document.metadata).to eq(nil)
        expect(KYCAID::Address).to receive(:create)
        expect(KYCAID::Verification).to receive(:create)

        KYC::Kycaid::AddressWorker.new.perform(address_params)
        expect(document.reload.metadata).not_to eq(nil)
      end
    end
  end

  describe 'failed verification' do
    before { allow_any_instance_of(KYC::Kycaid::AddressWorker).to receive(:address_params).and_return({}) }
    let(:unauthorized_response) { OpenStruct.new(error: { "type": 'unauthorized' }) }
    let(:unsuccessful_response) do
      OpenStruct.new(type: 'validation', errors: [{ "parameter": 'front_file', "message": 'Image is blured' }])
    end
    context 'unathorized' do
      before { allow(KYCAID::Address).to receive(:create).and_return(unauthorized_response) }

      it 'does not create a address because of error' do
        expect(document.metadata).to eq(nil)
        expect(KYCAID::Address).to receive(:create)
        expect(KYCAID::Verification).not_to receive(:create)

        KYC::Kycaid::AddressWorker.new.perform(address_params)
        expect(document.reload.metadata).to eq(nil)
      end
    end

    context 'validation failed' do
      before { allow(KYCAID::Address).to receive(:create).and_return(unsuccessful_response) }

      it 'does not create a address' do
        expect(document.metadata).to eq(nil)
        expect(KYCAID::Address).to receive(:create)

        KYC::Kycaid::AddressWorker.new.perform(address_params)
        expect(document.metadata).to eq(nil)
      end

      it 'gets a rejected label' do
        expect(document.metadata).to eq(nil)
        expect(document.user.labels.count).to eq(2)
        expect(document.user.labels.find_by(key: :address).value).to eq('pending')

        expect(KYCAID::Address).to receive(:create)

        KYC::Kycaid::AddressWorker.new.perform(address_params)
        expect(document.metadata).to eq(nil)
        expect(document.user.labels.count).to eq(2)
        expect(document.user.labels.find_by(key: :address).value).to eq('rejected')
      end
    end
  end
end
