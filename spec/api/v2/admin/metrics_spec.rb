# frozen_string_literal: true

require 'spec_helper'

describe API::V2::Admin::Metrics do
  include_context 'bearer authentication'
  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  describe 'GET /api/v2/admin/users' do
    let(:do_request) { get '/api/v2/admin/metrics', headers: auth_header }

    context 'admin user' do
      let(:test_user) { create(:user, role: 'admin') }

      it 'returns empty hashes if no activity in database' do
        do_request

        expect(response.status).to eq(200)
        expect(response.body).to eq("{\"signups\":{},\"sucessful_logins\":{},\"failed_logins\":{},\"pending_applications\":0}")

        result = JSON.parse(response.body)
        expect(result['signups']).to eq({})
        expect(result['sucessful_logins']).to eq({})
        expect(result['failed_logins']).to eq({})
      end

      context 'with data' do
        let!(:login_activity) { create(:activity, action: 'login', result: 'succeed', topic: 'session', user: test_user) }
        let!(:signup_activity) { create(:activity, action: 'signup', result: 'succeed', topic: 'account', user: test_user) }
        let!(:failed_login_activity) { create(:activity, topic: 'session', action: 'login', result: 'failed', user: test_user) }

        it 'returns data as expected' do
          do_request

          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['failed_logins']).not_to eq({})
          expect(JSON.parse(response.body)['sucessful_logins']).not_to eq({})
          expect(JSON.parse(response.body)['signups']).not_to eq({})
        end
      end
    end
  end
end
