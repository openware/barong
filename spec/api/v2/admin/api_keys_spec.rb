# frozen_string_literal: true

describe 'Api::V2::Admin::APIKeys' do
  include_context 'bearer authentication'

  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let!(:create_superadmin_permission) do
    create :permission,
           role: 'superadmin'
  end

  describe 'GET /api/v2/admin/api_keys' do
    let!(:test_user) { create(:user, otp: otp_enabled, role: 'superadmin') }
    let(:otp_enabled) { true }
    let!(:first_api_key) { create :api_key, key_holder_account: test_user }
    let!(:second_api_key) { create :api_key, key_holder_account: test_user }
    let(:expected_fields) do
      {
        kid: first_api_key.kid,
        state: first_api_key.state,
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
        expect(json_body.first.keys).to match_array %i[kid algorithm scope state created_at updated_at]
        expect(json_body.first).to include(expected_fields)
        expect(json_body.first).not_to include(:secret)
      end

      it 'Returns api keys for selected account in ASC order' do
        params[:ordering] = 'asc'
        params[:order_by] = 'id'
        do_request

        expect(response.status).to eq(200)
        expect(json_body.first.keys).to match_array %i[kid algorithm scope state created_at updated_at]
        expect(json_body.first).to include(expected_fields)
        expect(json_body.first).not_to include(:secret)
      end

      it 'Returns api keys for selected account in DESC order' do
        params[:ordering] = 'desc'
        params[:order_by] = 'id'
        do_request

        expect(response.status).to eq(200)
        expect(json_body.first.keys).to match_array %i[kid algorithm scope state created_at updated_at]
        expect(json_body.second).to include(expected_fields)
        expect(json_body.second).not_to include(:secret)
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

      it 'Returns error if api key attribute doesnt exist' do
        params[:uid] = test_user.uid
        params[:order_by] = 'length'
        do_request
        expect(response.status).to eq(422)
        expect(json_body.first).to include(:errors, ["api_keys.ordering.invalid_attribute"])
      end

      it 'Returns error if invalid ordering' do
        params[:uid] = test_user.uid
        params[:ordering] = 'res'
        do_request
        expect(response.status).to eq(422)
        expect(json_body.first).to include(:errors, ["api_keys.ordering.invalid_ordering"])
      end
    end
  end
end
