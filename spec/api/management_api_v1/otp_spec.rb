# frozen_string_literal: true

describe ManagementAPI::V1::OTP, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        otp_sign: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
      }
  end

  let!(:account) { create(:account, otp_enabled: otp_enabled) }

  describe 'POST /otp/sign' do
    let(:data) do
      {
        account_uid: account.uid,
        otp_code: valid_otp_code,
        jwt: jwt
      }
    end
    let(:signers) { %i[alex jeff] }
    let(:valid_otp_code) { '1111' }
    let(:invalid_otp_code) { '1234' }
    let(:jwt) { applogic_signed_jwt(amount: '1 BTC') }
    let(:otp_enabled) { true }
    let(:do_request) do
      post_json '/management_api/v1/otp/sign',
                multisig_jwt_management_api_v1({ data: data }, *signers)
    end
    let(:valid_payload_keys) do
      %i[payload signatures]
    end

    before do
      allow(Vault::TOTP).to receive(:validate?)
        .with(account.uid, valid_otp_code) { true }
      allow(Vault::TOTP).to receive(:validate?)
        .with(account.uid, invalid_otp_code) { false }
    end

    it 'signs a request' do
      do_request
      expect(json_body.keys).to eq(valid_payload_keys)
      expect(response.status).to eq 201
    end

    it 'renders an error when jwt is not a Hash' do
      data[:jwt] = 'invalid'
      do_request
      expect_body.to eq(error: 'JWT is invalid')
      expect(response.status).to eq 422
    end

    it 'renders an error when jwt is not RFC' do
      data[:jwt] = { data: 'invalid' }
      do_request
      expect(json_body[:error]).to include('JWT is invalid by the reason')
      expect(response.status).to eq 422
    end

    it 'renders an error when otp code is invalid' do
      data[:otp_code] = invalid_otp_code
      do_request
      expect_body.to eq(error: 'OTP code is invalid')
      expect(response.status).to eq 422
    end

    it 'renders an error when account is not found' do
      data[:account_uid] = 'invalid'
      do_request
      expect_body.to eq error: 'Record is not found'
      expect(response.status).to eq 404
    end

    context 'when data is blank' do
      let(:data) { {} }
      let(:errors) do
        [
          'Account UID is missing',
          'Account UID is empty',
          'OTP code is missing',
          'OTP code is empty',
          'JWT is missing',
          'JWT is empty'
        ].join(', ')
      end

      it 'renders errors' do
        do_request
        expect_body.to eq(error: errors)
        expect(response.status).to eq 422
      end
    end
  end
end
