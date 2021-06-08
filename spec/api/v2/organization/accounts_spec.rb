# frozen_string_literal: true

describe API::V2::Organization::Accounts, type: :request do
  include_context 'bearer authentication'
  include_context 'organization memberships'

  let!(:create_memberships) do
    # Assign users with organizations
    create(:membership, id: 2, user_id: 2, organization_id: 1, role: 'admin')
    create(:membership, id: 3, user_id: 3, organization_id: 3, role: 'member')
    create(:membership, id: 4, user_id: 4, organization_id: 3, role: 'member')
    create(:membership, id: 5, user_id: 5, organization_id: 5, role: 'member')
    create(:membership, id: 6, user_id: 6, organization_id: 3, role: 'accountant')
    create(:membership, id: 7, user_id: 6, organization_id: 4, role: 'member')
  end

  describe 'GET /api/v2/organization/accounts' do
    let(:url) { '/api/v2/organization/accounts' }

    it 'error when account not found' do
      get url, headers: auth_header

      expect(response.status).to eq 401
    end

    context 'user with AdminSwitchSession ability' do
      let(:test_user) { User.find(1) }

      it 'get all individual users' do
        get url, headers: auth_header
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 10
        expect(result.select { |m| m['uid'].nil? }.length).to eq 6
        expect(result.select { |m| m['oid'].nil? }.length).to eq 4
      end
    end

    context 'user is org-admin with SwitchSession ability' do
      let(:test_user) { User.find(2) }

      it 'get all accounts in the organization' do
        get url, headers: auth_header
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 3
      end

      it 'return list of accounts filtered account by organization name' do
        get url,
            headers: auth_header,
            params: { keyword: 'Company A' }
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 1
        expect(result[0]['name']).to eq 'Company A'
      end

      it 'return list of accounts filtered account by organization account name' do
        get url,
            headers: auth_header,
            params: { keyword: 'Group A1' }
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 1
        expect(result[0]['name']).to eq 'Group A1'
      end

      it 'return list of accounts filtered account by uid' do
        get url,
            headers: auth_header,
            params: { keyword: 'IDFE10A90000' }
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 1
        expect(result[0]['oid']).to eq 'OID001'
      end
    end

    context 'user is org-member with SwitchSession ability' do
      let(:test_user) { User.find(3) }

      it 'get account of the organization' do
        get url, headers: auth_header
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 1
      end

      it 'return list of accounts filtered account by organization account name' do
        get url,
            headers: auth_header,
            params: { keyword: 'Group A1' }
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 1
        expect(result[0]['name']).to eq 'Group A1'
      end
    end

    context 'user is org-member with multiple accounts and SwitchSession ability' do
      let(:test_user) { User.find(6) }

      it 'get multiple accounts of the organization' do
        get url, headers: auth_header
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 2
      end

      it 'return list of accounts filtered account by organization account named Group A1' do
        get url,
            headers: auth_header,
            params: { keyword: 'Group A1' }
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 1
        expect(result[0]['name']).to eq 'Group A1'
      end

      it 'return list of accounts filtered account by organization account named Group A2' do
        get url,
            headers: auth_header,
            params: { keyword: 'Group A2' }
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 1
        expect(result[0]['name']).to eq 'Group A2'
      end
    end
  end
end
