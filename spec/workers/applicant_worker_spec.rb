# frozen_string_literal: true

describe 'KYC::ApplicantWorker' do
  include_context 'bearer authentication'
  before { allow(Barong::App.config).to receive_messages(kyc_provider: 'kycaid') }

  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let(:profile) { create(:profile, country: "UA", state: 'submitted') }

  describe 'successful verification' do
    let(:successful_response) { OpenStruct.new(applicant_id: "84e51f8a0677a646fd185fc741717ad9a8b3") }
    let(:params) {{ type: 'PERSON', first_name: profile.first_name, last_name: profile.last_name, dob: profile.dob,
                    residence_country: profile.country, email: profile.user.email, phone: profile.user.phones&.last&.number }}

    before { allow(KYCAID::Applicant).to receive(:create).with(params).and_return(successful_response)}

    context 'perform' do
      it 'creates an applicant' do
        expect(profile.applicant_id).to eq(nil)
        expect(KYCAID::Applicant).to receive(:create)

        KYC::Kycaid::ApplicantWorker.new.perform(profile.id)
        expect(profile.reload.applicant_id).not_to eq(nil)
      end

      it 'changes a label to verified' do
        expect(profile.applicant_id).to eq(nil)
        expect(profile.user.labels.count).to eq(1)
        expect(profile.user.labels.first.key).to eq('profile')
        expect(profile.user.labels.first.value).to eq('submitted')

        expect(KYCAID::Applicant).to receive(:create)
        KYC::Kycaid::ApplicantWorker.new.perform(profile.id)

        expect(profile.reload.applicant_id).not_to eq(nil)
        expect(profile.user.labels.count).to eq(1)
        expect(profile.user.labels.first.key).to eq('profile')
        expect(profile.user.labels.first.value).to eq('verified')
      end
    end
  end

  describe 'failed verification' do
    let(:unauthorized_response) { OpenStruct.new(error: { "type": "unauthorized"}) }
    let(:unsuccessful_response) { 
      OpenStruct.new(type: "validation", errors: [{"parameter": "residence_country", "message": "Country of residence is not valid"}])
    }

    let(:params) {{ type: 'PERSON', first_name: profile.first_name, last_name: profile.last_name, dob: profile.dob,
                    residence_country: profile.country, email: profile.user.email, phone: profile.user.phones&.last&.number }}

    context 'unathorized' do
      before { allow(KYCAID::Applicant).to receive(:create).with(params).and_return(unauthorized_response)}

      it 'does not create an applicant' do
        expect(profile.applicant_id).to eq(nil)
        expect(KYCAID::Applicant).to receive(:create)

        KYC::Kycaid::ApplicantWorker.new.perform(profile.id)
        expect(profile.reload.applicant_id).to eq(nil)
      end
    end

    context 'validation failed' do
      before { allow(KYCAID::Applicant).to receive(:create).with(params).and_return(unsuccessful_response)}

      it 'does not create an applicant' do
        expect(profile.applicant_id).to eq(nil)
        expect(KYCAID::Applicant).to receive(:create)

        KYC::Kycaid::ApplicantWorker.new.perform(profile.id)
        expect(profile.reload.applicant_id).to eq(nil)
      end

      it 'gets a rejected label' do
        expect(profile.applicant_id).to eq(nil)
        expect(KYCAID::Applicant).to receive(:create)

        KYC::Kycaid::ApplicantWorker.new.perform(profile.id)
        expect(profile.reload.applicant_id).to eq(nil)
        expect(profile.user.labels.count).to eq(1)
        expect(profile.user.labels.first.key).to eq('profile')
        expect(profile.user.labels.first.value).to eq('rejected')
      end
    end
  end
end
