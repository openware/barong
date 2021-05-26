# frozen_string_literal: true

describe API::V2::Commercial::Accounts, type: :request do
  include_context 'bearer authentication'
  include_context 'organization memberships'

  describe 'GET /api/v2/commercial/accounts' do
    it 'error when account not found' do
      get '/api/v2/commercial/accounts', headers: auth_header

      expect(response.status).to eq 404
    end

    context 'user is barong organization admin' do
      let(:test_user) { User.find(1) }

      it 'get all organizations and accounts' do
        get '/api/v2/commercial/accounts', headers: auth_header
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 6
      end
    end

    context 'user is organization admin' do
      let(:test_user) { User.find(2) }
      let!(:create_memberships) do
        # Assign user as organization admin
        create(:membership, id: 1, user_id: 2, organization_id: 1)
      end

      it 'get all accounts in the organization' do
        get '/api/v2/commercial/accounts', headers: auth_header
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 3
      end

      it 'return list of accounts filtered account by organization name' do
        get '/api/v2/commercial/accounts',
            headers: auth_header,
            params: { keyword: 'Company A' }
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 1
        expect(result[0]['name']).to eq 'Company A'
      end

      it 'return list of accounts filtered account by organization account name' do
        get '/api/v2/commercial/accounts',
            headers: auth_header,
            params: { keyword: 'Group A1' }
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 1
        expect(result[0]['name']).to eq 'Group A1'
      end

      it 'return list of accounts filtered account by uid' do
        get '/api/v2/commercial/accounts',
            headers: auth_header,
            params: { keyword: 'IDFE10A90000' }
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 1
        expect(result[0]['uids']).to eq ['IDFE10A90000']
      end
    end

    context 'user is organization member' do
      let(:test_user) { User.find(3) }
      let!(:create_memberships) do
        # Assign user as organization member
        create(:membership, id: 1, user_id: 3, organization_id: 3)
      end

      it 'get account of the organization' do
        get '/api/v2/commercial/accounts', headers: auth_header
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 1
      end

      it 'get multiple accounts of the organization' do
        # Assign user as organization member
        create(:membership, id: 2, user_id: 3, organization_id: 4)

        get '/api/v2/commercial/accounts', headers: auth_header
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 2
      end

      it 'return list of accounts filtered account by organization account name' do
        # Assign user as organization member
        create(:membership, id: 2, user_id: 3, organization_id: 4)

        get '/api/v2/commercial/accounts',
            headers: auth_header,
            params: { keyword: 'Group A1' }
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 1
        expect(result[0]['name']).to eq 'Group A1'
      end
    end
  end
end
