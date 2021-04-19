# frozen_string_literal: true

describe 'Api::V1::Profiles' do
  include_context 'organization memberships'

  let(:test_user) { create(:user) }
  let(:switchs) { {} }
  let(:jwt_token) do
    pkey = Rails.application.config.x.keystore.private_key
    codec = Barong::JWT.new(key: pkey)
    codec.encode(test_user.as_payload.merge(switchs))
  end
  let(:auth_header) { { 'Authorization' => "Bearer #{jwt_token}" } }

  describe 'GET /api/v2/resource/users/me' do
    context 'User has no organization' do
      it 'return organization as nil' do
        get '/api/v2/resource/users/me', headers: auth_header

        expect(response.status).to eq(200)
        expect(json_body.key?(:organization)).to eq(true)
        expect(json_body[:organization]).to eq(nil)
      end
    end

    context 'User belong to the organization' do
      let(:test_user) { User.find(1) }

      it 'return nil for barong admin organization' do
        # Assign user as barong admin organization
        create(:membership, id: 1, user_id: 1, organization_id: 0)

        get '/api/v2/resource/users/me', headers: auth_header

        expect(response.status).to eq(200)
        expect(json_body.key?(:organization)).to eq(true)
        expect(json_body[:organization]).to eq(nil)
      end

      it 'return Company A for organization admin' do
        # Assign user as organization admin of Company A
        create(:membership, id: 1, user_id: 1, organization_id: 1)

        get '/api/v2/resource/users/me', headers: auth_header

        expect(response.status).to eq(200)
        expect(json_body[:organization][:name]).to eq('Company A')
      end

      it 'return Company A for organization account' do
        # Assign user as organization account of Company A
        create(:membership, id: 1, user_id: 1, organization_id: 3)

        get '/api/v2/resource/users/me', headers: auth_header

        expect(response.status).to eq(200)
        expect(json_body[:organization][:name]).to eq('Company A')
      end

      it 'return Company B for organization account' do
        # Assign user as organization account of Company A
        create(:membership, id: 1, user_id: 1, organization_id: 5)

        get '/api/v2/resource/users/me', headers: auth_header

        expect(response.status).to eq(200)
        expect(json_body[:organization][:name]).to eq('Company B')
      end
    end

    context 'User switch to be the organization account' do
      it 'return Company A when user switch to Company A' do
        switchs[:oid] = 'OID001'
        get '/api/v2/resource/users/me', headers: auth_header

        expect(response.status).to eq(200)
        expect(json_body[:organization][:name]).to eq('Company A')
      end

      it 'return Company B when user switch to Company A' do
        switchs[:oid] = 'OID002'
        get '/api/v2/resource/users/me', headers: auth_header

        expect(response.status).to eq(200)
        expect(json_body[:organization][:name]).to eq('Company B')
      end
    end
  end
end
