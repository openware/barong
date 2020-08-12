# frozen_string_literal: true

require 'spec_helper'
describe API::V2::Admin::Permissions do
  include_context 'bearer authentication'

  let!(:create_admin_permission) { create(:permission, role: 'superadmin', action: 'accept', verb: 'get') }
  let!(:test_user) { create(:user, role: 'superadmin') }
  let!(:create_member_permission) { create(:permission, role: 'member') }

  describe 'GET /api/v2/admin/permissions' do
    context 'successful response' do
      it 'returns all permissions' do
        get '/api/v2/admin/permissions', headers: auth_header

        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.count).to eq(Permission.count)
      end

      it 'returns paginated permissions' do
        get '/api/v2/admin/permissions', params: { limit: 1, page: 1 }, headers: auth_header
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(response.headers.fetch('Total')).to eq '2'
        expect(result.size).to eq 1
        expect(result.first['role']).to eq 'superadmin'

        get '/api/v2/admin/permissions', params: { limit: 1, page: 2 }, headers: auth_header
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(response.headers.fetch('Total')).to eq '2'
        expect(result.size).to eq 1
        expect(result.first['role']).to eq 'member'
      end
    end
  end

  describe 'POST /api/v2/admin/permissions' do
    context 'unsuccessful response' do
      it 'returns error while invalid verb creating' do
        post '/api/v2/admin/permissions', params: { role: 'admin', action: 'drop', verb: 'options', path: 'api/v2' }, headers: auth_header
        result = JSON.parse(response.body)

        expect(response.code).to eq '422'
        expect(result['errors']).to eq(['admin.permissions.invalid_verb'])
      end

      it 'returns error while invalid action creating' do
        post '/api/v2/admin/permissions', params: { role: 'admin', action: 'delete', verb: 'put', path: 'api/v2' }, headers: auth_header
        result = JSON.parse(response.body)

        expect(response.code).to eq '422'
        expect(result['errors']).to eq(['admin.permissions.invalid_action'])
      end

      it 'returns error while invalid role creating' do
        post '/api/v2/admin/permissions', params: { role: 'supertrader', action: 'accept', verb: 'put', path: 'api/v2' }, headers: auth_header
        result = JSON.parse(response.body)

        expect(response.code).to eq '422'
        expect(result['errors']).to eq(['admin.permission.role_doesnt_exist'])
      end

      it 'returns error while empty action creating' do
        post '/api/v2/admin/permissions', params: { role: 'supertrader', action: '', verb: 'put', path: 'api/v2' }, headers: auth_header
        result = JSON.parse(response.body)

        expect(response.code).to eq '422'
        expect(result['errors']).to eq(['admin.permission.empty_action'])
      end
    end

    context 'successful response' do
      let(:do_request) { post '/api/v2/admin/permissions', params: { role: 'superadmin', action: 'accept', verb: 'put', path: 'api/v2/admin' }, headers: auth_header }
      it 'creates new permission' do
        expect { do_request }.to change { Permission.count }.by(1)
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE /api/v2/admin/permissions' do
    context 'successful response' do
      let(:do_request) { delete '/api/v2/admin/permissions', params: { id: create_member_permission.id }, headers: auth_header }

      it 'delete permission' do
        expect { do_request }.to change { Permission.count }.by(-1)
        expect(response).to be_successful
      end
    end

    context 'unsuccessful response' do
      it 'return error while permission doesnt exist' do
        delete '/api/v2/admin/permissions', params: { id: 0 }, headers: auth_header
        result = JSON.parse(response.body)
        expect(response.code).to eq '404'
        expect(result['errors']).to eq(['admin.permission.doesnt_exist'])
      end
    end
  end

  describe 'PUT /api/v2/admin/permissions' do
    context 'successful response' do
      let(:permission) { Permission.find_by(id: create_admin_permission.id) }

      it 'returns updated path for permission' do
        put '/api/v2/admin/permissions', params: { id: create_admin_permission.id , path: 'api/v2/admin' }, headers: auth_header

        expect(response).to be_successful
        expect(permission.path).to eq 'api/v2/admin'
      end

      it 'returns updated verb for permission' do
        put '/api/v2/admin/permissions', params: { id: create_admin_permission.id , verb: 'PUT' }, headers: auth_header

        expect(response).to be_successful
        expect(permission.verb).to eq 'PUT'
      end

      it 'returns updated fileds for permission' do
        put '/api/v2/admin/permissions', params: { id: create_admin_permission.id , verb: 'POST', action: 'all', path: 'api/v2' }, headers: auth_header

        expect(response).to be_successful
        expect(permission.verb).to eq 'POST'
        expect(permission.action).to eq 'ALL'
        expect(permission.path).to eq 'api/v2'
      end
    end

    context 'unsuccessful response' do
      it 'return error while permission doesnt exist' do
        put '/api/v2/admin/permissions', params: { id: 0, action: 'accept' }, headers: auth_header

        result = JSON.parse(response.body)

        expect(response.code).to eq '404'
        expect(result['errors']).to eq(['admin.permission.doesnt_exist'])
      end
    end
  end
end
