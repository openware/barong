# frozen_string_literal: true

require 'spec_helper'

describe API::V2::Admin::Levels do
  include_context 'bearer authentication'
  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  describe 'GET /api/v2/admin/levels' do
    let(:do_request) { get '/api/v2/admin/levels', headers: auth_header }

    context 'admin user' do
      let(:test_user) { create(:user, role: 'admin') }

      it 'returns levels' do
        do_request

        expect(response.status).to eq(200)

        result = JSON.parse(response.body)

        expect(result.length).to eq(Level.count)

        result.each do |level|
          expected_level = Level.find(level['id'])

          expect(level['key']).to eq(expected_level.key)
          expect(level['value']).to eq(expected_level.value)
        end
      end
    end
  end
end
