# frozen_string_literal: true

describe API::V2::Organization::Users, type: :request do
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

  describe 'GET /api/v2/organization/users' do
    let(:do_request) { get '/api/v2/organization/users', headers: auth_header, params: params }

    let!(:create_memberships) do
      # Assign users with organizations
      create(:membership, id: 2, user_id: 2, organization_id: 1)
      create(:membership, id: 3, user_id: 3, organization_id: 3)
      create(:membership, id: 4, user_id: 4, organization_id: 3)
      create(:membership, id: 5, user_id: 5, organization_id: 5)
      create(:membership, id: 6, user_id: 6, organization_id: 3)
      create(:membership, id: 7, user_id: 6, organization_id: 4)
    end

    context 'user has Organization ability' do
      let(:test_user) { User.find(1) }

      it 'error when oid not provided' do
        do_request

        expect(response.status).to eq 422
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
  end

  describe 'POST /api/v2/organization/user' do
    let(:do_request) { post '/api/v2/organization/user', headers: auth_header, params: params }

    let!(:create_memberships) do
      # Assign users with organizations
      create(:membership, id: 2, user_id: 2, organization_id: 1)
      create(:membership, id: 3, user_id: 5, organization_id: 5)
    end

    context 'user has Organization ability' do
      let(:test_user) { User.find(1) }

      it 'return error if missing uid, oid, role' do
        do_request

        expect(response.status).to eq 422
      end

      it 'cannot add the same user in the same organization' do
        params[:uid] = 'IDFE10A90000'
        params[:oid] = 'OID001'
        params[:role] = 'org-admin'

        do_request

        expect(response.status).to eq 401
      end

      it 'can add organization admin in organization' do
        params[:uid] = 'IDFE0908101'
        params[:oid] = 'OID002'
        params[:role] = 'org-admin'

        do_request

        expect(response).to be_successful
        expect(::Membership.where(user_id: 7, organization_id: 2).length).to eq(1)
      end

      it 'can add organization account in organization' do
        params[:uid] = 'IDFE10A90001'
        params[:oid] = 'OID001AID001'
        params[:role] = 'org-member'

        do_request

        expect(response).to be_successful
        expect(::Membership.where(user_id: 3, organization_id: 3).length).to eq(1)
      end
    end
  end

  describe 'DELETE /api/v2/organization/user' do
    let(:do_request) { delete '/api/v2/organization/user', headers: auth_header, params: params }

    let!(:create_memberships) do
      # Assign users with organizations
      create(:membership, id: 2, user_id: 2, organization_id: 1)
      create(:membership, id: 3, user_id: 3, organization_id: 3)
      create(:membership, id: 4, user_id: 4, organization_id: 3)
      create(:membership, id: 5, user_id: 5, organization_id: 5)
      create(:membership, id: 6, user_id: 6, organization_id: 3)
      create(:membership, id: 7, user_id: 6, organization_id: 4)
    end

    context 'user has Organization ability' do
      let(:test_user) { User.find(1) }

      it 'need membership_id to delete user in organization' do
        do_request

        expect(response.status).to eq(422)
      end

      it 'can delete organization admin in organization' do
        params[:membership_id] = 2
        do_request

        expect(response).to be_successful
        expect(::Membership.where(id: 2).length).to eq(0)
      end

      it 'can delete organization user in organization' do
        params[:membership_id] = 3
        do_request

        expect(response).to be_successful
        expect(::Membership.where(id: 3).length).to eq(0)
      end
    end
  end

  describe 'GET /api/v2/organization/user/:uid' do
    let(:url) { '/api/v2/organization/user' }

    let!(:create_memberships) do
      # Assign users with organizations
      create(:membership, id: 2, user_id: 2, organization_id: 1, role: 'org-admin')
      create(:membership, id: 3, user_id: 6, organization_id: 3, role: 'org-member')
      create(:membership, id: 4, user_id: 6, organization_id: 4, role: 'org-accountant')
    end

    context 'user has Organization ability' do
      let(:test_user) { User.find(1) }

      it 'error when uid not provided' do
        get "#{url}/", headers: auth_header

        expect(response.status).to eq 404
      end

      it 'return empty of non-organization user' do
        get "#{url}/IDFE0908101", headers: auth_header

        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 0
      end

      it 'return organizations of adminA@barong.io' do
        get "#{url}/IDFE10A90000", headers: auth_header

        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 1
        expect(result[0]['parent_oid']).to eq('OID001')
        expect(result[0]['oid']).to eq(nil)
        expect(result[0]['role']).to eq('org-admin')
      end

      it 'return organizations of memberA1A2@barong.io' do
        get "#{url}/IDFE10A90003", headers: auth_header

        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 2

        expect(result[0]['parent_oid']).to eq('OID001')
        expect(result[0]['oid']).to eq('OID001AID001')
        expect(result[0]['role']).to eq('org-member')

        expect(result[1]['parent_oid']).to eq('OID001')
        expect(result[1]['oid']).to eq('OID001AID002')
        expect(result[1]['role']).to eq('org-accountant')
      end
    end
  end
end
