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

  describe 'POST /api/v1/accounts' do
    let(:do_request) do
      post '/api/v1/accounts', params: params
    end

    before { do_request }

    context 'when email is valid' do
      let(:params) { { email: 'valid.email@gmail.com', password: 'Password1' } }

      it 'creates an account' do
        expect_status_to_eq 201
      end
    end

    context 'denies when email or password is invalid' do
      let(:params) { { email: 'email@gmail.com', password: 'password' } }

      it 'renders an error' do
        expect_status_to_eq 422
        expect_body.to eq(error: ['Password does not meet the minimum system requirements. It should be composed of uppercase and lowercase letters, and numbers.'])
      end
    end

    context 'denies when email and password are absent' do
      let(:params) {}

      it 'renders an error' do
        expect_status_to_eq 400
        expect_body.to eq(error: 'Email is missing, Email is empty, Password is missing, Password is empty')
      end
    end
  end
end
