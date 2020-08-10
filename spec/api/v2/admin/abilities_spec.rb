# frozen_string_literal: true

describe API::V2::Admin::Abilities, type: :request do
  include_context 'bearer authentication'

  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end

  describe 'GET /api/v2/admin/abilities' do
    context 'superadmin user' do
      let(:test_user) { create(:user, email: 'example@gmail.com', role: 'admin') }
      it 'get all roles and permissions' do
        get '/api/v2/admin/abilities', headers: auth_header
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result).to eq(
          'read' => %w[Level APIKey Permission],
          'manage' => %w[User Activity Profile Label]
        )
      end
    end

    context 'member user' do
      let(:test_user) { create(:user, email: 'example@gmail.com', role: 'member') }
      it 'get all roles and permissions' do
        get '/api/v2/admin/abilities', headers: auth_header
        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result).to eq({})
      end
    end
  end
end
