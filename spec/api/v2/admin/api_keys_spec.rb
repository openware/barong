# frozen_string_literal: true

describe 'Api::V2::Admin::APIKeys' do
  include_context 'bearer authentication'

  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end

  describe 'GET /api/v2/admin/api_keys' do
    let!(:test_user) { create(:user, otp: otp_enabled) }
    let(:otp_enabled) { true }
    let!(:api_key) { create :api_key, user: test_user }
    let(:expected_fields) do
      {
        kid: api_key.kid,
        state: api_key.state,
        scope: %w[trade]
      }
    end
    let(:params) do
      {
        uid: test_user.uid
      }
    end
    let(:do_request) { get "/api/v2/admin/api_keys", params: params, headers: auth_header }

    context 'successful' do
      it 'Returns api keys for selected account' do
        do_request
        expect(response.status).to eq(200)
        expect(json_body.first).to include(expected_fields)
        expect(json_body.first).not_to include(:secret)
      end

      it 'Returns empty array if no api keys exist for selected account' do
        test_user.api_keys.delete_all

        do_request
        expect(response.status).to eq(200)
        expect(json_body).to eq([])
      end
    end

    context 'error' do
      let(:params) do
        {
          uid: 'random'
        }
      end

      it 'Returns error if user doesnt exist' do
        do_request
        expect(response.status).to eq(404)
        expect(json_body.first).to include(:errors, ["admin.user.doesnt_exist"])
      end
    end
  end
end
