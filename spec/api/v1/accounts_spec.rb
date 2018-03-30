require 'spec_helper'

describe 'Api::V1::Accounts' do
  include_context 'doorkeeper authentication'

  describe 'GET /api/account' do
    let(:do_request) { get '/api/account', headers: auth_header }
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

  describe 'POST /api/account' do
    let(:do_request) do
      post '/api/account', params: params
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
end
