require 'spec_helper'

describe 'Api::V1::Accounts' do
  include_context 'doorkeeper authentication'

  before { do_request }

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
      expect(response.status).to eq(200)
      expect(json_body).to eq(account_attrs)
    end
  end

  xdescribe 'POST /api/account' do
    let(:do_request) do
      post '/api/account', params: params, headers: auth_header
    end
  end
end
