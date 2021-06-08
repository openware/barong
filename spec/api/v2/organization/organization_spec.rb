# frozen_string_literal: true

describe API::V2::Organization::Organizations, type: :request do
  include_context 'bearer authentication'
  include_context 'organization memberships'

  describe 'GET /api/v2/organization' do
    let(:params) { {} }
    let(:do_request) { get '/api/v2/organization', headers: auth_header, params: params }

    let!(:create_memberships) do
      # Assign users with organizations
      create(:membership, id: 2, user_id: 2, organization_id: 1)
      create(:membership, id: 3, user_id: 3, organization_id: 3)
      create(:membership, id: 4, user_id: 4, organization_id: 3)
      create(:membership, id: 5, user_id: 5, organization_id: 5)
      create(:membership, id: 6, user_id: 6, organization_id: 3)
      create(:membership, id: 7, user_id: 6, organization_id: 4)
    end

    context 'when params is missing' do
      it 'renders an error' do
        get '/api/v2/organization', headers: auth_header

        expect(response.status).not_to eq(200)
      end
    end

    context 'user has Organization ability' do
      let(:params) { { oid: 'OID001' } }
      let(:test_user) { User.find(1) }

      it 'return organization details of default user\'s organization' do
        do_request
        result = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(result['oid']).to eq('OID001')
      end

      it 'return organization details' do
        params[:oid] = 'OID001'
        do_request
        result = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(result['name']).to eq('Company A')
      end

      it 'return organization account details' do
        params[:oid] = 'OID001AID001'

        do_request
        result = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(result['name']).to eq('Group A1')
      end
    end
  end

  describe 'PUT /api/v2/organization/update' do
    context 'when params is missing' do
      it 'renders an error' do
        put '/api/v2/organization/update', headers: auth_header

        expect_status_to_eq 422
      end
    end

    context 'user is normal user' do
      let(:do_request) do
        put '/api/v2/organization/update',
             headers: auth_header,
             params: { organization_id: 1 }
      end
      let(:test_user) { User.find(7) }

      it 'deny request from normal user' do
        do_request

        expect(response.status).to eq(401)
      end
    end

    context 'user has Organization ability' do
      let(:params) { { organization_id: 1 } }
      let(:do_request) do
        put '/api/v2/organization/update',
             headers: auth_header,
             params: params
      end
      let(:test_user) { User.find(1) }

      it 'can update organization details' do
        params[:name] = 'Company Test'
        do_request

        expect(response.status).to eq(200)
        expect(::Organization.find(1).name).to eq('Company Test')
      end
    end
  end

  describe 'PUT /api/v2/organization/settings' do
    context 'when params is missing' do
      it 'renders an error' do
        put '/api/v2/organization/settings', headers: auth_header

        expect_status_to_eq 422
      end
    end

    context 'user is normal user' do
      let(:do_request) do
        put '/api/v2/organization/settings',
             headers: auth_header,
             params: { organization_id: 1 }
      end
      let(:test_user) { User.find(7) }

      it 'deny request from normal user' do
        do_request

        expect(response.status).to eq(401)
      end
    end

    context 'user has Organization ability' do
      let(:params) { { organization_id: 1 } }
      let(:do_request) do
        put '/api/v2/organization/settings',
             headers: auth_header,
             params: params
      end
      let(:test_user) { User.find(1) }

      it 'update organization status' do
        params[:status] = 'banned'
        do_request

        expect(response.status).to eq(200)
        expect(::Organization.find(1).status).to eq('banned')
      end

      it 'update organization group' do
        params[:group] = 'vip-1'
        do_request

        expect(response.status).to eq(200)
        expect(::Organization.find(1).group).to eq('vip-1')
      end
    end
  end

  describe 'GET /api/v2/organization/abilities' do
    let(:do_request) { get '/api/v2/organization/abilities', headers: auth_header }

    context 'user has AdminSwitchSession ability' do
      let(:test_user) { User.find(1) }

      it 'return AdminSwitchSession abilities' do
        do_request
        result = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(result['manage']).to eq(['AdminSwitchSession'])
      end
    end

    context 'user has SwitchSession ability' do
      let(:test_user) { User.find(2) }

      it 'return SwitchSession abilities' do
        do_request
        result = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(result['manage']).to eq(['SwitchSession'])
      end
    end

    context 'user has no AdminSwitchSession/SwitchSession ability' do
      let(:test_user) { User.find(7) }

      it 'return SwitchSession abilities' do
        do_request
        result = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(result).to eq({})
      end
    end
  end
end
