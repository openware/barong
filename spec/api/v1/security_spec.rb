# frozen_string_literal: true

require 'spec_helper'

describe 'Api::V1::Security' do
  include_context 'doorkeeper authentication'

  describe 'POST /api/v1/security/renew' do
    let(:url) { '/api/v1/security/renew' }

    it 'Checks if current JWT is valid and returns new valid JWT' do
      post url, headers: auth_header
      expect(response.status).to eq(201)

      post url,
           headers: { Authorization: "Bearer #{JSON.parse(response.body)}" }
      expect(response.status).to eq(201)
    end

    it 'Checks if current JWT is valid and returns JWT with specified liftime' do
      post url, params: { expires_in: 1000 }, headers: auth_header
      expect(response.status).to eq(201)
      new_jwt_payload = JWT.decode JSON.parse(response.body), nil, false
      expect(new_jwt_payload.first['exp'].to_i).to be <= Time.now.to_i + 1000
    end

    it 'Checks if current JWT is valid and returns error, cause it is not' do
      post url
      expect(response.body).to eq('{"error":"The access token is invalid"}')
    end

    it 'Checks if current JWT is valid and returns error, cause it has expired' do
      post url, params: { expires_in: 1 }, headers: auth_header
      expect(response.status).to eq(201)
      new_jwt = JSON.parse(response.body)
      sleep(2)
      post url, headers: { 'Authorization' => "Bearer #{new_jwt}" }
      expect(response.body).to eq('{"error":"The access token expired"}')
    end
  end

  describe 'POST /api/v1/security/generate_qrcode' do
    let(:do_request) do
      post '/api/v1/security/generate_qrcode', headers: auth_header
    end

    context 'when otp enabled' do
      let(:current_account) { create(:account, otp_enabled: true) }

      it 'renders an error' do
        do_request
        expect(response.status).to eq(400)
        expect(json_body).to eq(error: 'You are already enabled 2FA')
      end
    end

    context 'when otp do not enabled' do
      it 'generates qr code' do
        expect(Vault::TOTP).to receive(:create) { true }
        do_request
        expect(response.status).to eq(201)
      end
    end
  end

  describe 'POST /api/v1/security/enable_2fa' do
    let(:do_request) do
      post '/api/v1/security/enable_2fa', params: params, headers: auth_header
    end

    let(:params) { { code: code } }
    let(:code) { '12345' }

    context 'when code is missing' do
      let(:code) { '' }

      it 'renders an error' do
        do_request
        expect(json_body).to eq(error: 'code is empty')
        expect(response.status).to eq(400)
      end
    end

    context 'when otp is already enabled' do
      let(:current_account) { create(:account, otp_enabled: true) }

      it 'renders an error' do
        do_request
        expect(response.status).to eq(400)
        expect(json_body).to eq(error: 'You are already enabled 2FA')
      end
    end

    context 'when code is invalid' do
      before do
        expect(Vault::TOTP).to receive(:validate?)
          .with(current_account.uid, code) { false }
      end

      it 'renders an error' do
        do_request
        expect(response.status).to eq(422)
        expect(json_body).to eq(error: 'Your code is invalid')
      end
    end

    context 'when code is valid' do
      before do
        expect(Vault::TOTP).to receive(:validate?)
          .with(current_account.uid, code) { true }
      end

      it 'responses with success' do
        do_request
        expect(response.status).to eq(201)
      end

      it 'enables otp' do
        expect { do_request }.to change { current_account.reload.otp_enabled }
          .from(false).to(true)
      end
    end
  end

  describe 'POST /api/v1/security/verify_code' do
    let(:do_request) do
      post '/api/v1/security/verify_code', params: params, headers: auth_header
    end

    let(:current_account) { create(:account, otp_enabled: otp_enabled) }
    let(:params) { { code: code } }
    let(:code) { '12345' }
    let(:otp_enabled) { true }

    context 'when code is missing' do
      let(:code) { '' }

      it 'renders an error' do
        do_request
        expect(response.status).to eq(400)
        expect(json_body).to eq(error: 'code is empty')
      end
    end

    context 'when otp do not enabled' do
      let(:otp_enabled) { false }

      it 'renders an error' do
        do_request
        expect(response.status).to eq(400)
        expect(json_body).to eq(error: 'You need to enable 2FA first')
      end
    end

    context 'when code is invalid' do
      before do
        expect(Vault::TOTP).to receive(:validate?)
          .with(current_account.uid, code) { false }
      end

      it 'renders an error' do
        do_request
        expect(response.status).to eq(422)
        expect(json_body).to eq(error: 'Your code is invalid')
      end
    end

    context 'when code is valid' do
      before do
        expect(Vault::TOTP).to receive(:validate?)
          .with(current_account.uid, code) { true }
      end

      it 'responses with success' do
        do_request
        expect(response.status).to eq(201)
      end
    end
  end

  describe 'POST /api/v1/security/reset_password' do
    let(:do_request) do
      post '/api/v1/security/reset_password', params: params
    end
    let(:params) { { email: email } }

    context 'when email is unknown' do
      let(:email) { 'unknown@example.com' }

      it 'renders not found error' do
        expect(Devise::Mailer).to_not receive(:reset_password_instructions)
        do_request
        expect(response.status).to eq(404)
      end
    end

    context 'when account is found by email' do
      let!(:account) { create(:account, email: email) }
      let(:email) { 'email@example.com' }
      let(:fake_mailer) { double(deliver: '') }

      it 'sends reset password instructions' do
        expect(Devise::Mailer).to receive(:reset_password_instructions) { fake_mailer }
        do_request
        expect(response.status).to eq(201)
      end
    end
  end

  describe 'PUT /api/v1/security/reset_password' do
    let(:do_request) do
      put '/api/v1/security/reset_password', params: params
    end
    let(:params) do
      {
        reset_password_token: reset_password_token,
        password: password
      }
    end
    let(:reset_password_token) { '' }
    let(:password) { '' }

    context 'when params are blank' do
      it 'renders 400 error' do
        do_request
        expect(response.status).to eq(400)
        expect_body.to eq(error: 'reset_password_token is empty, password is empty')
      end
    end

    context 'when reset_password_token is invalid' do
      let(:reset_password_token) { 'invalid' }
      let(:password) { 'password' }

      it 'renders 404 error' do
        do_request
        expect(response.status).to eq(404)
        expect_body.to eq(error: 'Record is not found')
      end
    end

    context 'when reset_password_token is valid' do
      let!(:account) { create(:account) }
      let(:reset_password_token) { account.send_reset_password_instructions }
      let(:password) { 'password' }

      it 'resets a password' do
        expect { do_request }.to change { account.reload.encrypted_password }
        expect(response.status).to eq(200)
      end
    end
  end
end
