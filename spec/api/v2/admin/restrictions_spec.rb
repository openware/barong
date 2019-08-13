# frozen_string_literal: true

require 'spec_helper'
describe API::V2::Admin::Restrictions do
  include_context 'bearer authentication'

  before { create(:permission, role: 'member') }

  describe 'GET /api/v2/admin/restrictions' do
    before do
      create(:restriction, scope: 'ip', value: '0.0.0.1', updated_at: 1.days.ago)
      create(:restriction, scope: 'ip', value: '0.0.0.0', updated_at: 3.days.ago)
      create(:restriction, scope: 'ip_subnet', value: '1.2.3.4/24', updated_at: 3.days.ago)
    end

    context 'successful response' do
      it 'returns all restrictions' do
        get '/api/v2/admin/restrictions', headers: auth_header

        expect(response).to be_successful
        expect(json_body.count).to eq(Restriction.count)
      end

      it 'filters by scope' do
        get '/api/v2/admin/restrictions', headers: auth_header, params: { scope: 'ip' }

        expect(json_body.length).to eq Restriction.where(scope: 'ip').count
        expect(json_body.map { |r| r[:scope] }).to all eq 'ip'
      end

      it 'filters with date range' do
        get '/api/v2/admin/restrictions', headers: auth_header, params: { from: 2.days.ago.to_i, range: 'updated' }

        expected = Restriction.where("updated_at >= ?", 2.days.ago)
        expect(json_body.map { |r| r[:id] }).to match_array expected.map(&:id)
      end

      it 'returns paginated restrictions' do
        get '/api/v2/admin/restrictions', headers: auth_header, params: { limit: 1 }
        result = json_body

        expect(response).to be_successful
        expect(response.headers.fetch('Total')).to eq '3'
        expect(result.size).to eq 1
      end
    end
  end

  describe 'POST /api/v2/admin/restrictions' do
    it 'creates new restriction' do
      expect {
        post '/api/v2/admin/restrictions', headers: auth_header, params: { scope: 'ip', value: '127.0.0.0' }
      }.to change { Restriction.count }.by(1)

      expect(response).to be_successful
    end

    context 'validation' do
      it 'scope and state' do
        post '/api/v2/admin/restrictions', headers: auth_header, params: { scope: 'office', value: '127.0.0.0', state: 'running' }

        expect(json_body[:errors]).to include "admin.restriction.invalid_scope"
        expect(json_body[:errors]).to include "admin.restriction.invalid_state"
      end

      it 'value' do
        post '/api/v2/admin/restrictions', headers: auth_header, params: { scope: 'ip', value: '127.a.b.c' }

        expect(json_body[:errors]).to include "value.invalid"
      end
    end
  end

  describe 'PUT /api/v2/admin/restrictions' do
    let!(:restriction) { create(:restriction, scope: 'ip', value: '127.0.0.1') }

    it 'updates state' do
      expect {
        put '/api/v2/admin/restrictions', headers: auth_header, params: { id: restriction.id, state: 'disabled' }
      }.to change { restriction.reload.state }.to('disabled')
    end

    it 'updates value' do
      expect {
        put '/api/v2/admin/restrictions', headers: auth_header, params: { id: restriction.id, value: '192.168.0.1' }
      }.to change { restriction.reload.value }.to('192.168.0.1')
    end

    it 'does not change scope if value becomes invalid' do
      expect {
        put '/api/v2/admin/restrictions', headers: auth_header, params: { id: restriction.id, scope: 'ip_subnet' }
      }.not_to change { restriction.reload.scope }
    end

    it 'validates value' do
      put '/api/v2/admin/restrictions', headers: auth_header, params: { id: restriction.id, value: '192.168.0.abc' }

      expect(response).not_to be_successful
    end

    it 'updates scope' do
      expect {
        put '/api/v2/admin/restrictions', headers: auth_header, params: { id: restriction.id, scope: 'ip_subnet', value: '192.168.0.1/24' }
      }.to change { restriction.reload.scope }.to('ip_subnet').and change { restriction.reload.value }.to '192.168.0.1/24'
    end
  end
end
