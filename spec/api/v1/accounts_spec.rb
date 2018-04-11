# frozen_string_literal: true

require 'spec_helper'

describe 'Api::V1::Accounts' do
  include_context 'doorkeeper authentication'

  describe 'GET /api/v1/account' do
    let(:do_request) { get '/api/v1/account', headers: auth_header }
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

  describe 'POST /api/v1/account' do
    let(:do_request) do
      post '/api/v1/account', params: params
    end

    before { do_request }

    context 'when email is invalid' do
      let(:params) { { email: 'bad_format', password: 'password' } }

      it 'renders an error' do
        expect_status_to_eq 422
        expect_body.to eq(error: ['Email is invalid'])
      end
    end

    context 'when email is blank' do
      let(:params) { { email: '', password: 'password' } }

      it 'renders an error' do
        expect_status_to_eq 422
        expect_body.to eq(error: ["Email can't be blank"])
      end
    end

    context 'when email and password are absent' do
      let(:params) {}

      it 'renders an error' do
        expect_status_to_eq 400
        expect_body.to eq(error: 'email is missing, password is missing')
      end
    end

    context 'when email is valid' do
      let(:params) { { email: Faker::Internet.email, password: 'password' } }

      it 'creates an account' do
        expect_status_to_eq 201
      end
    end
  end
  describe 'PUT /api/v1/account/password' do
    let(:url) { '/api/v1/account/password' }
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

    subject!(:acc) do
      create :account,
             password: password0,
             password_confirmation: password0
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

    it 'Checks if credentials are valid and returns error, cause they are not' do
      put url, params: params1, headers: headers
      expect(response.status).to eq(401)
      expect(response.body).to eq('{"error":"401 Unauthorized"}')

      put url
      expect(response.status).to eq(401)
      expect(response.body).to eq('{"error":"The access token is invalid"}')

      put url, params: params0.except(:new_password), headers: headers
      expect(response.status).to eq(400)
      expect(response.body).to eq('{"error":"new_password is missing"}')

      put url, params: params0.except(:old_password), headers: headers
      expect(response.status).to eq(400)
      expect(response.body).to eq('{"error":"old_password is missing"}')
    end
  end
end
