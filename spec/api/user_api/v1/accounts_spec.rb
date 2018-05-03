# frozen_string_literal: true

require 'spec_helper'

describe 'Api::V1::Accounts' do
  include_context 'jwt authentication'

  describe 'GET /api/v1/accounts/me' do
    let(:do_request) { get '/api/v1/accounts/me', headers: auth_header }
    let(:account_attrs) do
      {
        uid: current_account.uid,
        email: current_account.email,
        level: current_account.level,
        role: current_account.role,
        state: current_account.state
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

    before { do_request }

    context 'when email is invalid' do
      let(:params) { { email: 'bad_format', password: 'password' } }

      it 'renders an error' do
        expect_status_to_eq 422
        expect_body.to eq(error: ['Email is invalid'])
      end
    end

    context 'when email and password are absent' do
      let(:params) {}

      it 'renders an error' do
        expect_status_to_eq 400
        expect_body.to eq(error: 'email is missing, email is empty, password is missing, password is empty')
      end
    end

    context 'when email is blank' do
      let(:params) { { email: '', password: 'password' } }

      it 'renders an error' do
        expect_status_to_eq 400
        expect_body.to eq(error: 'email is empty')
      end
    end

    context 'when email is valid' do
      let(:params) { { email: Faker::Internet.email, password: 'password' } }

      it 'creates an account' do
        expect_status_to_eq 201
      end
    end
  end

  describe 'PUT /api/v1/accounts/password' do
    let(:url) { '/api/v1/accounts/password' }
    let!(:password0) { 'testpassword111' }
    let!(:password1) { 'testpassword123' }
    let(:params0) do
      {
        old_password: password0,
        new_password: password1
      }
    end

    let(:params1) do
      {
        old_password: password1,
        new_password: password0
      }
    end

    let(:current_account) do
      create :account,
             password: password0,
             password_confirmation: password0
    end

    it 'Checks if provided credentials are valid and changes password to the new one' do
      put url, params: params0, headers: auth_header
      expect(response.status).to eq(200)

      put url, params: params1, headers: auth_header
      expect(response.status).to eq(200)
    end

    it 'renders 401 when old password is invalid' do
      put url, params: params1, headers: auth_header
      expect(response.body).to eq('{"error":"Invalid password."}')
      expect(response.status).to eq(401)
    end

    it 'renders 401 without auth header' do
      put url, params: params0
      expect_body.to eq(error: 'Authorization failed')
      expect(response.status).to eq(401)
    end

    it 'renders 400 when new password is missing' do
      put url, params: params0.except(:new_password), headers: auth_header
      expect(response.body).to eq('{"error":"new_password is missing"}')
      expect(response.status).to eq(400)
    end

    it 'renders 400 is old password is missing' do
      put url, params: params0.except(:old_password), headers: auth_header
      expect(response.body).to eq('{"error":"old_password is missing"}')
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
        expect_body.to eq(error: 'confirmation_token is empty')
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
end
