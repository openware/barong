# frozen_string_literal: true

require 'rails_helper'
require 'pry'

describe API::V2::Management::Otp, type: :request do
  before do
    defaults_for_management_api_v2_security_configuration!
    management_api_v2_security_configuration.merge! \
      scopes: {
        otp_sign: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
      }
  end
  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let!(:user) { create(:user, otp: otp_enabled) }

  describe 'POST /otp/sign' do
    let(:data) do
      {
        user_uid: user.uid,
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
      post_json '/api/v2/management/otp/sign',
                multisig_jwt_management_api_v2({ data: data }, *signers)
    end
    let(:valid_payload_keys) do
      %i[payload signatures]
    end

    before do
      allow(TOTPService).to receive(:validate?)
        .with(user.uid, valid_otp_code) { true }
      allow(TOTPService).to receive(:validate?)
        .with(user.uid, invalid_otp_code) { false }
    end

    it 'signs a request' do
      do_request
      expect(json_body.keys).to eq(valid_payload_keys)
      expect(response.status).to eq 201
    end

    it 'renders an error when jwt is not a Hash' do
      data[:jwt] = 'invalid'
      do_request
      expect_body.to eq(error: 'jwt is invalid')
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
      data[:user_uid] = 'invalid'
      do_request
      expect_body.to eq error: 'Record is not found'
      expect(response.status).to eq 404
    end

    context 'when data is blank' do
      let(:data) { {} }

       it 'renders errors' do
        do_request
        expect_body.to eq(error: "user_uid is missing, user_uid is empty, otp_code is missing, otp_code is empty, jwt is missing, jwt is empty")
        expect(response.status).to eq 422
      end
    end
  end
end
