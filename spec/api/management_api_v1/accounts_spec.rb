# frozen_string_literal: true

describe ManagementAPI::V1::Accounts, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        read_accounts: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
      }
  end

  let!(:account) { create(:account, :with_profile) }

  describe 'Show account info' do
    let(:data) do
      {
        uid: account.uid,
        scope: :read_accounts
      }
    end
    let(:expected_attributes) do
      {
      }
    end
    let(:signers) { %i[alex jeff] }

    let(:do_request) do
      post_json '/management_api/v1/accounts/get',
                multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    it 'reads account info' do
      do_request
      expect(response.status).to eq 201
      expect(json_body.keys).to eq %i[email role level otp_enabled state profile created_at updated_at]
    end

    it 'denies access unless enough signatures are supplied' do
      signers.clear.concat %i[james jeff]
      do_request
      expect(response.status).to eq 401
    end

    it 'denies when account is not found' do
      data[:uid] = 'invalid'
      do_request
      expect(response.status).to eq 404
    end

    context 'when data is blank' do
      let(:data) { {} }

      it 'renders errors' do
        do_request
        expect(response.status).to eq 422
        expect_body.to eq(error: 'UID is missing, UID is empty')
      end
    end
  end
end
