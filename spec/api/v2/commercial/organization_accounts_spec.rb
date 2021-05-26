# frozen_string_literal: true

describe API::V2::Commercial::Organizations, type: :request do
  include_context 'organization memberships'

  let(:test_user) { create(:user) }
  let(:switchs) { {} }
  let(:params) { {} }
  let(:jwt_token) do
    pkey = Rails.application.config.x.keystore.private_key
    codec = Barong::JWT.new(key: pkey)
    codec.encode(test_user.as_payload.merge(switchs))
  end
  let(:auth_header) { { 'Authorization' => "Bearer #{jwt_token}" } }

  describe 'GET /api/v2/commercial/organization/accounts' do
    let(:do_request) { get '/api/v2/commercial/organization/accounts', headers: auth_header, params: params }

    let!(:create_memberships) do

      # Assign users with organizations
      create(:membership, id: 2, user_id: 2, organization_id: 1)
      create(:membership, id: 3, user_id: 3, organization_id: 3)
      create(:membership, id: 4, user_id: 4, organization_id: 3)
      create(:membership, id: 5, user_id: 5, organization_id: 5)
      create(:membership, id: 6, user_id: 6, organization_id: 3)
      create(:membership, id: 7, user_id: 6, organization_id: 4)
    end

    context 'user is not belong to any organization' do
      let(:test_user) { User.find(7) }
      it 'error when user try to get organization users' do
        do_request

        expect(response.status).to eq 401
      end
    end

    context 'user is barong admin organization' do
      let(:test_user) { User.find(1) }

      it 'error when oid not provided' do
        do_request

        expect(response.status).to eq 400
      end

      it 'error when oid is not valid' do
        params[:oid] = 'INVALID001'
        do_request

        expect(response.status).to eq 404
      end

      it 'error when oid is not parent organization' do
        params[:oid] = 'OID001AID001'
        do_request

        expect(response.status).to eq 404
      end

      it 'return accounts of Company A' do
        params[:oid] = 'OID001'
        do_request

        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 2
      end

      it 'return accounts of Company B' do
        params[:oid] = 'OID002'
        do_request

        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 2
      end
    end

    context 'user is organization admin' do
      let(:test_user) { User.find(2) }

      it 'return account of Company A' do
        do_request

        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 2
      end

      it 'ignore oid params and return account of Company A' do
        params[:oid] = 'OID002AID002'
        do_request

        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 2
      end
    end
  end

  describe 'POST /api/v2/commercial/organization/accounts' do
    let(:do_request) { post '/api/v2/commercial/organization/accounts', headers: auth_header, params: params }

    let!(:create_memberships) do
      # Assign users with organizations
      create(:membership, id: 2, user_id: 2, organization_id: 1)
      create(:membership, id: 3, user_id: 5, organization_id: 5)
    end

    context 'user is not belong to any organization' do
      let(:test_user) { User.find(7) }
      it 'error when user try to add organization user' do
        params[:organization_id] = 7
        params[:name] = 'Group Test'
        params[:status] = 'active'

        do_request

        expect(response.status).not_to eq 200
      end
    end

    context 'user is barong admin organization' do
      let(:test_user) { User.find(1) }

      it 'return error if missing organization_id, name, status' do
        do_request

        expect(response.status).to eq 422
      end

      it 'cannot add organization as parent organizations' do
        params[:organization_id] = nil
        params[:name] = 'Group Test'
        params[:status] = 'active'

        do_request

        expect(response.status).to eq 401
      end

      it 'cannot add the same organization name in the same parent' do
        params[:organization_id] = 2
        params[:name] = 'Group B1'
        params[:status] = 'active'

        do_request

        expect(response.status).to eq 401
      end

      it 'can add organization in parent organization' do
        params[:organization_id] = 1
        params[:name] = 'Group A3'
        params[:status] = 'active'

        do_request
        org = Organization.last

        expect(response).to be_successful
        expect(org.parent_id).to eq(1)
        expect(org.name).to eq('Group A3')
      end

      it 'can add organization among parent organizations' do
        params[:organization_id] = 2
        params[:name] = 'Group B3'
        params[:status] = 'active'

        do_request
        org = Organization.last

        expect(response).to be_successful
        expect(org.parent_id).to eq(2)
        expect(org.name).to eq('Group B3')
      end

      it 'cannot add organization into sub-organization' do
        params[:organization_id] = 5
        params[:name] = 'Sub Group B1'
        params[:status] = 'active'

        do_request

        expect(response.status).to eq 401
      end
    end

    context 'user is organization admin' do
      let(:test_user) { User.find(2) }

      it 'cannot add organization in other parent organization which user does not belong to' do
        params[:organization_id] = 2
        params[:name] = 'Group B3'
        params[:status] = 'active'

        do_request

        expect(response.status).to eq 401
      end

      it 'can add organization in parent organization' do
        params[:organization_id] = 1
        params[:name] = 'Group A3'
        params[:status] = 'active'

        do_request
        org = Organization.last

        expect(response).to be_successful
        expect(org.parent_id).to eq(1)
        expect(org.name).to eq('Group A3')
      end
    end

    context 'user is organization account' do
      let(:test_user) { User.find(5) }

      it 'cannot add organization in parent organization' do
        params[:organization_id] = 2
        params[:name] = 'Group B3'
        params[:status] = 'active'

        do_request

        expect(response.status).to eq 401
      end
    end
  end

  describe 'DELETE /api/v2/commercial/organization/accounts' do
    let(:do_request) { delete '/api/v2/commercial/organization/accounts', headers: auth_header, params: params }

    let!(:create_memberships) do
      # Assign users with organizations
      create(:membership, id: 2, user_id: 2, organization_id: 1)
      create(:membership, id: 3, user_id: 3, organization_id: 3)
      create(:membership, id: 4, user_id: 4, organization_id: 3)
      create(:membership, id: 5, user_id: 5, organization_id: 5)
      create(:membership, id: 6, user_id: 6, organization_id: 3)
      create(:membership, id: 7, user_id: 6, organization_id: 4)
    end

    context 'user is not belong to any organization' do
      let(:test_user) { User.find(7) }
      it 'error when user try to delete organization account' do
        params[:organization_id] = 3
        do_request

        expect(response.status).not_to eq 200
      end
    end

    context 'user is barong admin organization' do
      let(:test_user) { User.find(1) }

      it 'need organization_id to delete account in organization' do
        do_request

        expect(response.status).to eq 422
      end

      it 'cannot delete parent organization' do
        params[:organization_id] = 1
        do_request

        expect(response.status).to eq 404
      end

      it 'can delete organization account' do
        params[:organization_id] = 3
        do_request

        expect(response).to be_successful
        expect(Organization.where(id: 3).length).to eq(0)
      end
    end

    context 'user is organization admin' do
      let(:test_user) { User.find(2) }

      it 'cannot delete parent organization' do
        params[:organization_id] = 1
        do_request

        expect(response.status).to eq 404
      end

      it 'can delete organization account' do
        params[:organization_id] = 3
        do_request

        expect(response).to be_successful
        expect(Organization.where(id: 3).length).to eq(0)
      end

      it 'cannot delete organization account in other organization' do
        params[:organization_id] = 5
        do_request

        expect(response.status).to eq 401
      end
    end

    context 'user is organization account' do
      let(:test_user) { User.find(5) }

      it 'cannot delete organization account in organization' do
        params[:organization_id] = 5

        do_request

        expect(response.status).to eq 401
      end
    end
  end
end
