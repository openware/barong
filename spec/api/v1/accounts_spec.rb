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

  describe 'PATCH /api/account/confirm' do
    let(:do_request) do
      patch '/api/account/confirm', params: params, headers: auth_header
    end
    let!(:current_account) { create(:account, confirmed_at: nil) }

    let(:params) { }

    context 'when required params are missing' do
      let(:error_message) do
        'confirmation_token is missing'
      end

      it 'renders an error' do
        do_request
        expect_status_to_eq 400
        expect_body.to eq(error: error_message)
      end
    end

    context 'when confirmation token is invalid' do
      let(:params) do
        {
          confirmation_token: 'token'
        }
      end

      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(error: 'Confirmation token is invalid')
      end
    end

    context 'when account is confirmed' do
      let(:params) do
        {
          confirmation_token: current_account.confirmation_token
        }
      end

      it 'renders an error' do
        current_account.confirm
        do_request
        expect_status_to_eq 422
        expect_body.to eq(error: 'Account is already confirmed')
      end
    end

    context "when all requirements is pass" do
      let(:params) do
        {
          confirmation_token: current_account.confirmation_token
        }
      end

      it 'confirms an account' do
        do_request
        expect_status_to_eq 200
      end
    end
  end
end
