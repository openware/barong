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
  let(:test_user) { create(:user, email: 'example@gmail.com', role: 'admin') }

  describe 'GET /api/v2/admin/abilities' do
    it 'get all roles and permissions' do
      get '/api/v2/admin/abilities',  headers: auth_header
      result = JSON.parse(response.body)
      expect(response).to be_successful
      expect(result['roles'].count).to eq 7
      expect(result['roles']).to eq ['admin', 'manager', 'accountant', 'superadmin', 'technical', 'compliance', 'support']

      expect(result['permissions'].count).to eq 4
      expect(result['permissions']['superadmin'].keys).to eq ['manage']
    end
  end
end