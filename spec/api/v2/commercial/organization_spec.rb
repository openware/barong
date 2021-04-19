# frozen_string_literal: true

describe API::V2::Commercial::Organizations, type: :request do
  include_context 'bearer authentication'
  include_context 'organization memberships'

  describe 'GET /api/v2/commercial/organization' do
    let(:params) { {} }
    let(:do_request) { get '/api/v2/commercial/organization', headers: auth_header, params: params }

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
        get '/api/v2/commercial/organization', headers: auth_header

        expect(response.status).not_to eq(200)
      end
    end

    context 'user is barong organization admin' do
      let(:params) { { oid: 'OID001' } }
      let(:test_user) { User.find(1) }

      it 'deny request from normal user' do
        do_request

        expect(response.status).to eq(401)
      end

      it 'return organization details for barong organization admin' do
        # Assign user as barong organization admin
        create(:membership, id: 1, user_id: 1, organization_id: 0)

        do_request

        expect(response.status).to eq(200)
      end
    end

    context 'user is organization admin' do
      let(:test_user) { User.find(2) }

      it 'return organization admin details of default user\'s organization' do
        do_request

        expect(response.status).to eq(200)
      end

      it 'return organization admin details' do
        params[:oid] = 'OID001'
        do_request

        expect(response.status).to eq(200)
      end

      it 'cannot get organization account details of other organization' do
        params[:oid] = 'OID002'
        do_request

        expect(response.status).to eq(401)
      end

      it 'return organization account details' do
        params[:oid] = 'OID001AID001'

        do_request

        expect(response.status).to eq(200)
      end

      it 'cannot get organization admin details of other organization' do
        params[:oid] = 'OID002AID002'
        do_request

        expect(response.status).to eq(401)
      end
    end

    context 'user is organization account' do
      let(:test_user) { User.find(3) }

      it 'cannot get organization account details' do
        params[:oid] = 'OID001AID001'

        do_request

        expect(response.status).to eq(401)
      end
    end
  end

  describe 'POST /api/v2/commercial/organization/update' do
    context 'when params is missing' do
      it 'renders an error' do
        post '/api/v2/commercial/organization/update', headers: auth_header

        expect_status_to_eq 422
      end
    end

    context 'user is normal user' do
      let(:do_request) do
        post '/api/v2/commercial/organization/update',
             headers: auth_header,
             params: { organization_id: 1 }
      end
      let(:test_user) { User.find(1) }

      it 'deny request from normal user' do
        do_request

        expect(response.status).to eq(401)
      end
    end

    context 'user is barong admin organization user' do
      let(:params) { { organization_id: 1 } }
      let(:do_request) do
        post '/api/v2/commercial/organization/update',
             headers: auth_header,
             params: params
      end
      let(:test_user) { User.find(1) }

      it 'can update organization details' do
        # Assign user as barong admin organization
        create(:membership, id: 1, user_id: 1, organization_id: 0)

        params[:name] = 'Company Test'
        do_request

        expect(response.status).to eq(200)
      end

      it 'error when data not change' do
        # Assign user as barong admin organization
        create(:membership, id: 1, user_id: 1, organization_id: 0)

        params[:name] = 'Company A'
        do_request

        expect(response.status).to eq(422)
      end
    end

    context 'user is organization admin' do
      let(:params) { {} }
      let(:do_request) do
        post '/api/v2/commercial/organization/update',
             headers: auth_header,
             params: params
      end
      let!(:create_memberships) do
        # Assign users with organizations
        create(:membership, id: 2, user_id: 2, organization_id: 1)
      end
      let(:test_user) { User.find(2) }

      it 'cannot update organization details' do
        params[:organization_id] = 1
        params[:name] = 'Company Test'
        do_request

        expect(response.status).to eq(401)
      end

      it 'can update organization account details' do
        params[:organization_id] = 3
        params[:name] = 'Company Test'
        do_request

        expect(response.status).to eq(200)
      end

      it 'cannot update organization account details of other organization' do
        params[:organization_id] = 5
        params[:name] = 'Company Test'
        do_request

        expect(response.status).to eq(401)
      end
    end
  end

  describe 'POST /api/v2/commercial/organization/setting' do
    context 'when params is missing' do
      it 'renders an error' do
        post '/api/v2/commercial/organization/setting', headers: auth_header

        expect_status_to_eq 422
      end
    end

    context 'user is normal user' do
      let(:do_request) do
        post '/api/v2/commercial/organization/setting',
             headers: auth_header,
             params: { organization_id: 1 }
      end
      let(:test_user) { User.find(1) }

      it 'deny request from normal user' do
        do_request

        expect(response.status).to eq(401)
      end
    end

    context 'user is barong admin organization user' do
      let(:params) { { organization_id: 1 } }
      let(:do_request) do
        post '/api/v2/commercial/organization/setting',
             headers: auth_header,
             params: params
      end
      let(:test_user) { User.find(1) }

      it 'update organization status' do
        # Assign user as barong organization admin
        create(:membership, id: 1, user_id: 1, organization_id: 0)

        params[:status] = 'banned'
        do_request

        expect(response.status).to eq(200)
      end

      it 'update organization group' do
        # Assign user as barong organization admin
        create(:membership, id: 1, user_id: 1, organization_id: 0)

        params[:group] = 'vip-1'
        do_request

        expect(response.status).to eq(200)
      end

      it 'error when data not change' do
        # Assign user as barong organization admin
        create(:membership, id: 1, user_id: 1, organization_id: 0)

        params[:status] = 'active'
        do_request

        expect(response.status).to eq(422)
      end
    end

    context 'user is organization admin' do
      let(:params) { {} }
      let(:do_request) do
        post '/api/v2/commercial/organization/setting',
             headers: auth_header,
             params: params
      end
      let!(:create_memberships) do
        # Assign users with organizations
        create(:membership, id: 2, user_id: 2, organization_id: 1)
      end
      let(:test_user) { User.find(2) }

      it 'cannot update organization details' do
        params[:organization_id] = 1
        params[:status] = 'banned'
        do_request

        expect(response.status).to eq(401)
      end

      it 'can update organization account details' do
        params[:organization_id] = 3
        params[:status] = 'banned'
        do_request

        expect(response.status).to eq(200)
      end

      it 'cannot update organization account details of other organization' do
        params[:organization_id] = 5
        params[:status] = 'banned'
        do_request

        expect(response.status).to eq(401)
      end
    end
  end
end
