# frozen_string_literal: true

require 'spec_helper'

describe 'Api::V1::Accounts' do
  include_context 'doorkeeper authentication'

  describe 'GET /api/v1/accounts/me' do
    let(:do_request) { get '/api/v1/accounts/me', headers: auth_header }
    let(:account_attrs) do
      {
        uid: current_account.uid,
        email: current_account.email,
        level: current_account.level,
        role: current_account.role,
        state: current_account.state,
        otp_enabled: current_account.otp_enabled
      }
    end

    it 'gets current account' do
      do_request
      expect(response.status).to eq(200)
      expect(json_body).to eq(account_attrs)
    end
  end

  describe 'POST /api/v1/accounts' do
    let(:do_request) do
      post '/api/v1/accounts', params: params
    end

    context 'when email is invalid' do
      let(:params) { { email: 'bad_format', password: 'Password1' } }

      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(error: ['Email is invalid', 'Password has previously appeared in a data breach and should never be used. Please choose something harder to guess.'])
      end
    end

    context 'when Password is invalid' do
      let(:params) { { email: 'vadid.email@gmail.com', password: 'password' } }

      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(error: ['Password does not meet the minimum system requirements. It should be composed of uppercase and lowercase letters, and numbers.', 'Password has previously appeared in a data breach and should never be used. Please choose something harder to guess.'])
      end
    end

    context 'when email and password are absent' do
      let(:params) {}

      it 'renders an error' do
        do_request
        expect_status_to_eq 400
        expect_body.to eq(error: 'Email is missing, Email is empty, Password is missing, Password is empty')
      end
    end

    context 'when email is blank' do
      let(:params) { { email: '', password: 'zieV0Kai' } }

      it 'renders an error' do
        do_request
        expect_status_to_eq 400
        expect_body.to eq(error: 'Email is empty')
      end
    end

    context 'when email is valid' do
      let(:params) { { email: 'vadid.email@gmail.com', password: 'eeC2BiCu' } }

      it 'creates an account' do
        do_request
        expect_status_to_eq 201
      end
    end

    context 'when captcha is enabled' do
      before { ENV['CAPTCHA_ENABLED'] = 'true' }
      after { ENV['CAPTCHA_ENABLED'] = nil }

      context 'when captcha response is blank' do
        let(:params) { { email: 'vadid.email@gmail.com', password: 'quooR4ew' } }

        it 'renders an error' do
          do_request
          expect(json_body[:error]).to eq('recaptcha_response is required')
          expect_status_to_eq 400
        end
      end

      context 'when captcha response is not valid' do
        let(:params) do
          {
            email: 'vadid.email@gmail.com',
            password: 'eFo8aesi',
            recaptcha_response: 'invalid'
          }
        end

        before do
          expect_any_instance_of(RecaptchaVerifier).to receive(:verify_recaptcha) { false }
        end

        it 'renders an error' do
          do_request
          expect(json_body[:error]).to eq('reCAPTCHA verification failed, please try again.')
          expect_status_to_eq 422
        end
      end

      context 'when captcha response is valid' do
        let(:params) do
          {
            email: 'vadid.email@gmail.com',
            password: 'Deivoh3a',
            recaptcha_response: 'invalid'
          }
        end

        before do
          expect_any_instance_of(RecaptchaVerifier).to receive(:verify_recaptcha) { true }
        end

        it 'creates an account' do
          do_request
          expect_status_to_eq 201
        end
      end
    end
  end

  describe 'PUT /api/v1/accounts/password' do
    let(:url) { '/api/v1/accounts/password' }
    let!(:password0) { 'Aeth7sha' }
    let!(:password1) { 'Iene0eej' }
    let(:params0) do
      {
        old_password: 'faezu6Te',
        new_password: 'Aijae7gu'
      }
    end

    let(:params1) do
      {
        old_password: 'Aijae7gu',
        new_password: 'quee2ooV'
      }
    end

    subject!(:acc) do
      create :account,
             password: 'faezu6Te',
             password_confirmation: 'faezu6Te'
    end

    let!(:access_token) do
      create :doorkeeper_token,
             resource_owner_id: acc.id
    end

    let(:headers) do
      { Authorization: "Bearer #{access_token.token}" }
    end

    it 'Checks if provided credentials are valid and changes password to the new one' do
      put url, params: params0, headers: headers
      expect(response.status).to eq(200)

      put url, params: params1, headers: headers
      expect(response.status).to eq(200)
    end

    it 'renders 401 when old Password is invalid' do
      put url, params: params1, headers: headers
      expect_body.to eq(error: 'Invalid password')
      expect(response.status).to eq(401)
    end

    it 'renders 401 without auth header' do
      put url, params: params0
      expect_body.to eq(error: 'The access token is invalid')
      expect(response.status).to eq(401)
    end

    it 'renders 400 when new Password is missing' do
      put url, params: params0.except(:new_password), headers: headers
      expect_body.to eq(error: 'New Password is missing')
      expect(response.status).to eq(400)
    end

    it 'renders 400 is old Password is missing' do
      put url, params: params0.except(:old_password), headers: headers
      expect_body.to eq(error: 'Old Password is missing')
      expect(response.status).to eq(400)
    end
  end

  describe 'POST /api/v1/accounts/confirm' do
    let(:do_request) do
      post '/api/v1/accounts/confirm', params: { confirmation_token: confirmation_token }
    end

    context 'when token is blank' do
      let(:confirmation_token) { '' }
      it 'renders an error' do
        do_request
        expect_status_to_eq 400
        expect_body.to eq(error: 'Confirmation Token is empty')
      end
    end

    context 'when token is invalid' do
      let(:confirmation_token) { 'invalid' }
      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(error: 'Confirmation token is invalid')
      end
    end

    context 'when account is confirmed' do
      let!(:account) { create(:account, confirmed_at: nil) }
      let(:confirmation_token) { account.confirmation_token }

      it 'renders an error' do
        account.confirm
        do_request
        expect_status_to_eq 422
        expect_body.to eq(error: 'Email was already confirmed, please try signing in')
      end
    end

    context 'when account is not confirmed' do
      let!(:account) { create(:account, confirmed_at: nil) }
      let(:confirmation_token) { account.confirmation_token }

      it 'confirms an account' do
        do_request
        expect_status_to_eq 201
      end
    end
  end

  describe 'POST /api/v1/accounts/send_confirmation_instructions' do
    let!(:account) { create(:account, confirmed_at: confirmed_at) }

    let(:do_request) do
      post '/api/v1/accounts/send_confirmation_instructions',
           params: { email: account.email }
    end

    context 'when account is confirmed' do
      let(:confirmed_at) { 1.minute.ago }

      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(error: 'Email was already confirmed, please try signing in')
      end
    end

    context 'when account is not confirmed' do
      let(:confirmed_at) { nil }

      it 'sends instructions' do
        do_request
        expect_status_to_eq 201
        expect_body.to eq(message: 'Confirmation instructions was sent successfully')
      end
    end
  end

  describe 'POST /api/v1/accounts/unlock' do
    let(:do_request) do
      post '/api/v1/accounts/unlock', params: { unlock_token: unlock_token }
    end

    context 'when token is blank' do
      let(:unlock_token) { '' }
      it 'renders an error' do
        do_request
        expect_status_to_eq 400
        expect_body.to eq(error: 'unlock_token is empty')
      end
    end

    context 'when token is invalid' do
      let(:unlock_token) { 'invalid' }
      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(error: 'Unlock token is invalid')
      end
    end

    context 'when account is not locked' do
      let!(:account) { create(:account, locked_at: nil) }
      let(:unlock_token) { 'some_token' }

      it 'renders an error' do
        account.confirm
        do_request
        expect_body.to eq(error: 'Unlock token is invalid')
        expect_status_to_eq 422
      end
    end

    context 'when account is locked' do
      let!(:account) { create(:account) }
      let(:unlock_token) { account.lock_access! }

      it 'unlocks an account' do
        do_request
        expect_status_to_eq 201
      end
    end
  end

  describe 'POST /api/v1/accounts/send_unlock_instructions' do
    let!(:account) { create(:account, locked_at: locked_at) }

    let(:do_request) do
      post '/api/v1/accounts/send_unlock_instructions',
           params: { email: account.email }
    end

    context 'when account is not locked' do
      let(:locked_at) { nil }

      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(error: 'Email was not locked')
      end
    end

    context 'when account is locked' do
      let(:locked_at) { Time.now }

      it 'sends instructions' do
        do_request
        expect_status_to_eq 201
        expect_body.to eq(message: 'Unlock instructions was sent successfully')
      end
    end
  end
end
