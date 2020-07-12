# frozen_string_literal: true

describe 'KYC::Kycaid::VerificationWorker' do
  before { allow(Barong::App.config).to receive_messages(kyc_provider: 'kycaid') }

  include_context 'bearer authentication'
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let(:user) { create(:user) }
  let!(:profile) { create(:profile, country: 'UA', state: 'submitted', applicant_id: '84e51f8a0677a646fd185fc741717ad9a8b3', user_id: user.id) }
  let!(:document) { create(:document, identificator: '84e51f8a06', doc_type: 'Passport', doc_category: 'front_side', user_id: user.id) }
  let!(:document_second) { create(:document, identificator: '84e51f8a06', doc_type: 'Passport', doc_category: 'selfie', user_id: user.id) }

  describe 'successful verifications' do
    let(:successful_verification_response) { OpenStruct.new(status: 'completed', verifications: { document: { verified: true } }) }
    before { allow(KYCAID::Verification).to receive(:fetch).and_return(successful_verification_response) }

    context 'perform' do
      it 'fetches verification data' do
        expect(user.labels.count).to eq(2)
        expect(user.labels.find_by(key: :document, scope: :private).value).to eq('pending')

        expect(KYCAID::Verification).to receive(:fetch)

        KYC::Kycaid::VerificationsWorker.new.perform({ applicant_id: profile.applicant_id, verification_id: '84e51f8a' })
      end

      it 'changes label accordingly to verification' do
        expect(user.labels.count).to eq(2)
        expect(user.labels.find_by(key: :document, scope: :private).value).to eq('pending')

        expect(KYCAID::Verification).to receive(:fetch)

        KYC::Kycaid::VerificationsWorker.new.perform({ applicant_id: profile.applicant_id, verification_id: '84e51f8a' })

        expect(user.labels.count).to eq(2)
        expect(user.labels.reload.find_by(key: :document, scope: :private).value).to eq('verified')
      end
    end
  end

  describe 'failed verification' do
    let(:unsuccessful_response) { OpenStruct.new(status: 'completed', verifications: { document: { verified: false } }) }
    before { allow(KYCAID::Verification).to receive(:fetch).and_return(unsuccessful_response) }

    let(:unauthorized_response) { OpenStruct.new(error: { "type": 'unauthorized' }) }

    context 'unathorized' do
      before { allow(KYCAID::Verification).to receive(:fetch).and_return(unauthorized_response) }

      it 'does not create a document because of error' do
        expect(user.labels.count).to eq(2)
        expect(user.labels.find_by(key: :document, scope: :private).value).to eq('pending')

        expect(KYCAID::Verification).to receive(:fetch)

        KYC::Kycaid::VerificationsWorker.new.perform({ applicant_id: profile.applicant_id, verification_id: '84e51f8a' })
        expect(user.labels.reload.find_by(key: :document, scope: :private).value).to eq('pending')
      end
    end

    context 'verification declined' do
      it 'fetches verification data' do
        expect(user.labels.count).to eq(2)
        expect(user.labels.find_by(key: :document, scope: :private).value).to eq('pending')

        expect(KYCAID::Verification).to receive(:fetch)

        KYC::Kycaid::VerificationsWorker.new.perform({ applicant_id: profile.applicant_id, verification_id: '84e51f8a' })
      end

      it 'changes label accordingly to verification' do
        expect(user.labels.count).to eq(2)
        expect(user.labels.find_by(key: :document, scope: :private).value).to eq('pending')

        expect(KYCAID::Verification).to receive(:fetch)

        KYC::Kycaid::VerificationsWorker.new.perform({ applicant_id: profile.applicant_id, verification_id: '84e51f8a' })

        expect(user.labels.count).to eq(2)
        expect(user.labels.reload.find_by(key: :document, scope: :private).value).to eq('rejected')
      end
    end
  end
end
