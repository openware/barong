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

  describe 'GET /api/v2/commercial/organization/users' do
    let(:do_request) { get '/api/v2/commercial/organization/users', headers: auth_header, params: params }

    let!(:create_memberships) do
      # Assign user as barong admin organization
      create(:membership, id: 1, user_id: 1, organization_id: 0)

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

      it 'return users of Company A' do
        params[:oid] = 'OID001'
        do_request

        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 5
      end

      it 'return users of Group A1' do
        params[:oid] = 'OID001AID001'
        do_request

        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 3
      end
    end

    context 'user is organization admin with default organization' do
      let(:test_user) { User.find(2) }

      it 'return users of Company A' do
        switchs[:oid] = 'OID001'
        do_request

        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 5
      end
    end

    context 'user is organization admin with params' do
      let(:test_user) { User.find(2) }

      it 'error when oid is not valid' do
        params[:oid] = 'INVALID001'
        do_request

        expect(response.status).to eq 404
      end

      it 'return users of Company A' do
        params[:oid] = 'OID001'
        do_request

        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 5
      end

      it 'return users of Group A1' do
        params[:oid] = 'OID001AID001'
        do_request

        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 3
      end

      it 'error when user try to get Company B users' do
        params[:oid] = 'OID002'
        do_request

        expect(response.status).to eq 401
      end

      it 'error when user try to get Group B1 users' do
        params[:oid] = 'OID002AID002'
        do_request

        expect(response.status).to eq 401
      end
    end
  end

  describe 'POST /api/v2/commercial/organization/users' do
    let(:do_request) { post '/api/v2/commercial/organization/users', headers: auth_header, params: params }

    let!(:create_memberships) do
      # Assign user as barong admin organization
      create(:membership, id: 1, user_id: 1, organization_id: 0)

      # Assign users with organizations
      create(:membership, id: 2, user_id: 2, organization_id: 1)
      create(:membership, id: 3, user_id: 5, organization_id: 5)
    end

    context 'user is not belong to any organization' do
      let(:test_user) { User.find(7) }
      it 'error when user try to add organization user' do
        params[:user_id] = 7
        params[:organization_id] = 2

        do_request

        expect(response.status).not_to eq 200
      end
    end

    context 'user is barong admin organization' do
      let(:test_user) { User.find(1) }

      it 'return error if missing user_id, organization_id' do
        do_request

        expect(response.status).to eq 422
      end

      it 'cannot add barong admin organizations' do
        params[:user_id] = 7
        params[:organization_id] = 0

        do_request

        expect(response.status).to eq 401
      end

      it 'cannot add the same user in the same organization' do
        params[:user_id] = 2
        params[:organization_id] = 1

        do_request

        expect(response.status).to eq 401
      end

      it 'can add organization admin in organization' do
        params[:user_id] = 7
        params[:organization_id] = 2

        do_request

        expect(response).to be_successful
      end

      it 'can add organization account in organization' do
        params[:user_id] = 3
        params[:organization_id] = 3

        do_request

        expect(response).to be_successful
      end
    end

    context 'user is organization admin' do
      let(:test_user) { User.find(2) }

      it 'cannot add organization admin in organization' do
        params[:user_id] = 7
        params[:organization_id] = 1

        do_request

        expect(response.status).to eq 401
      end

      it 'cannot add organization account in other organization' do
        params[:user_id] = 7
        params[:organization_id] = 5

        do_request

        expect(response.status).to eq 401
      end

      it 'can add organization account in organization' do
        params[:user_id] = 7
        params[:organization_id] = 3

        do_request

        expect(response).to be_successful
      end
    end

    context 'user is organization account' do
      let(:test_user) { User.find(5) }

      it 'cannot add organization account in organization' do
        params[:user_id] = 7
        params[:organization_id] = 3

        do_request

        expect(response.status).to eq 401
      end
    end
  end

  describe 'DELETE /api/v2/commercial/organization/users' do
    let(:do_request) { delete '/api/v2/commercial/organization/users', headers: auth_header, params: params }

    let!(:create_memberships) do
      # Assign user as barong admin organization
      create(:membership, id: 1, user_id: 1, organization_id: 0)

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
      it 'error when user try to delete organization user' do
        params[:membership_id] = 1
        do_request

        expect(response.status).not_to eq 200
      end
    end

    context 'user is barong admin organization' do
      let(:test_user) { User.find(1) }

      it 'need membership_id to delete user in organization' do
        do_request

        expect(response.status).to eq 422
      end

      it 'cannot delete admin of all organizations' do
        params[:membership_id] = 1
        do_request

        expect(response.status).to eq 404
      end

      it 'can delete organization admin in organization' do
        params[:membership_id] = 2
        do_request

        expect(response).to be_successful
      end

      it 'can delete organization user in organization' do
        params[:membership_id] = 3
        do_request

        expect(response).to be_successful
      end
    end

    context 'user is organization admin' do
      let(:test_user) { User.find(2) }

      it 'cannot delete organization admin in organization' do
        params[:membership_id] = 2
        do_request

        expect(response.status).to eq 401
      end

      it 'can delete organization user in organization' do
        params[:membership_id] = 3
        do_request

        expect(response).to be_successful
      end

      it 'cannot delete organization user in other organization' do
        params[:membership_id] = 5
        do_request

        expect(response.status).to eq 401
      end
    end

    context 'user is organization account' do
      let(:test_user) { User.find(5) }

      it 'cannot delete organization user in organization' do
        params[:membership_id] = 5

        do_request

        expect(response.status).to eq 401
      end
    end
  end
end
