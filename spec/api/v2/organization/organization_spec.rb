# frozen_string_literal: true

describe API::V2::Organization::Organizations, type: :request do
  include_context 'bearer authentication'
  include_context 'organization memberships'

  describe 'GET /api/v2/organization' do
    let(:params) { {} }
    let(:url) { get '/api/v2/organization', headers: auth_header, params: params }

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
        get '/api/v2/organization/info', headers: auth_header

        expect(response.status).not_to eq(200)
      end
    end

    context 'user has Organization ability' do
      let(:url) { '/api/v2/organization/info' }
      let(:test_user) { User.find(1) }

      it 'return organization details' do
        get "#{url}/OID001", headers: auth_header
        result = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(result['name']).to eq('Company A')
      end

      it 'return organization account details' do
        get "#{url}/OID001AID001", headers: auth_header
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

  describe 'GET /api/v2/organization/switch_session_ability' do
    let(:do_request) { get '/api/v2/organization/switch_session_ability', headers: auth_header }

    let!(:create_memberships) do
      # Assign users with organizations
      create(:membership, id: 2, user_id: 2, organization_id: 1)
      create(:membership, id: 3, user_id: 3, organization_id: 3)
      create(:membership, id: 6, user_id: 6, organization_id: 3)
      create(:membership, id: 7, user_id: 6, organization_id: 4)
    end

    context 'user has AdminSwitchSession ability' do
      let(:test_user) { User.find(1) }

      it 'return true' do
        do_request
        result = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(result['ability']).to eq(true)
        expect(result['switch']).to eq(true)
      end
    end

    context 'user has no AdminSwitchSession/SwitchSession ability' do
      let(:test_user) { User.find(7) }

      it 'return false' do
        do_request
        result = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(result['ability']).to eq(false)
        expect(result['switch']).to eq(false)
      end
    end

    context 'user is Organization Admin' do
      let(:test_user) { User.find(2) }

      it 'return true' do
        do_request
        result = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(result['ability']).to eq(true)
        expect(result['switch']).to eq(true)
      end
    end

    context 'user is Organization Member with only 1 organization account' do
      let(:test_user) { User.find(3) }

      it 'return false' do
        do_request
        result = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(result['ability']).to eq(true)
        expect(result['switch']).to eq(false)
      end
    end

    context 'user is Organization Member with 2 organization accounts' do
      let(:test_user) { User.find(6) }

      it 'return true' do
        do_request
        result = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(result['ability']).to eq(true)
        expect(result['switch']).to eq(true)
      end
    end

    context 'user is Organization Admin which not belong to any organization' do
      let(:test_user) { User.find(11) }

      it 'return false' do
        do_request
        result = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(result['ability']).to eq(false)
        expect(result['switch']).to eq(false)
      end
    end

    context 'user is Organization Member which not belong to any organization' do
      let(:test_user) { User.find(4) }

      it 'return false' do
        do_request
        result = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(result['ability']).to eq(false)
        expect(result['switch']).to eq(false)
      end
    end
  end
end
