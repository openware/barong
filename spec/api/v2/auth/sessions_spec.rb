# frozen_string_literal: true

require 'spec_helper'
include ActiveSupport::Testing::TimeHelpers

describe '/api/v2/auth functionality test' do
  include_context 'geoip mock'

  let(:session_expire_time) do
    Barong::App.config.session_expire_time.to_i.seconds
  end
  let!(:create_permissions) do
    create :permission, role: 'admin'
    create :permission, role: 'member', action: 'ACCEPT', verb: 'all', path: 'not_in_the_rules_path'
    create :permission, role: 'member', action: 'ACCEPT', verb: 'get', path: '/api/v2/resource/users/me'
    create :permission, role: 'accountant'
  end
  let!(:user) { create(:user) }
  let(:params) do
    {
      email: user.email,
      password: user.password
    }
  end

  let(:do_destroy_session_request) { delete '/api/v2/identity/sessions', headers: { 'HTTP_USER_AGENT': 'legacy-browser' } }
  let(:do_create_session_request) { post '/api/v2/identity/sessions', params: params, headers: { 'HTTP_USER_AGENT': 'legacy-browser' } }
  let(:auth_request) { '/api/v2/auth/not_in_the_rules_path' }

  describe 'testing session hash validations' do
    before do
      Rails.cache.delete('permissions')
    end

    context 'with valid ip, browser' do
      it 'authorize traffic' do
        do_create_session_request
        expect(response.status).to eq(200)
        post auth_request, headers: { 'HTTP_USER_AGENT': 'legacy-browser' }

        expect(response.status).to eq(200)
        expect(response.headers['Authorization']).not_to be_nil
        expect(response.headers['Authorization']).to include "Bearer"
      end
    end

    context 'when session params has changed after session opening' do
      it 'return error if USER_AGENT changes' do
        do_create_session_request
        expect(response.status).to eq(200)

        post auth_request, headers: { 'HTTP_USER_AGENT': 'new-browser' }
        expect(response.status).to eq(401)
        expect(response.headers['Authorization']).to be_nil
      end

      it 'return error if IP changes' do
        do_create_session_request
        expect(response.status).to eq(200)

        post auth_request, headers: { 'REMOTE_ADDR': '128.0.0.12' }
        expect(response.status).to eq(401)
        expect(response.headers['Authorization']).to be_nil
      end

      it 'return error if everything changes' do
        do_create_session_request
        expect(response.status).to eq(200)

        post auth_request, headers: { 'REMOTE_ADDR': '128.0.0.12', 'HTTP_USER_AGENT': 'new-browser' }
        expect(response.status).to eq(401)
        expect(response.headers['Authorization']).to be_nil
      end
    end
  end

  describe 'testing session renewal' do
    before do
      Rails.cache.delete('permissions')
    end

    context 'with valid session' do
      it 'authorize traffic and renew session every request' do
        do_create_session_request
        expect(response.status).to eq(200)

        post auth_request, headers: { 'HTTP_USER_AGENT': 'legacy-browser' }

        expect(response.status).to eq(200)
        expect(response.headers['Authorization']).not_to be_nil
        expect(response.headers['Authorization']).to include "Bearer"
        start_time = Time.current

        30.times do
          # 5 minute before session will expire
          travel session_expire_time - 5.minutes

          # renew session with private request
          post auth_request, headers: { 'HTTP_USER_AGENT': 'legacy-browser' }

          expect(response.status).to eq(200)
          expect(response.headers['Authorization']).not_to be_nil
          expect(response.headers['Authorization']).to include "Bearer"
        end

        expect(Time.current).to be > (start_time + session_expire_time)

        travel session_expire_time + 10.minutes
        post auth_request, headers: { 'HTTP_USER_AGENT': 'legacy-browser' }
        expect(response.status).to eq(401)
      end
    end
  end

  describe 'testing session destroy' do
    before do
      Rails.cache.delete('permissions')
    end

    context 'with valid session' do
      it 'deletes session from cache on #logout' do
        do_create_session_request
        expect(response.status).to eq(200)

        post auth_request, headers: { 'HTTP_USER_AGENT': 'legacy-browser' }

        expect(response.status).to eq(200)
        expect(response.headers['Authorization']).not_to be_nil
        expect(response.headers['Authorization']).to include "Bearer"

        do_destroy_session_request
        expect(response.status).to eq(200)

        post auth_request, headers: { 'HTTP_USER_AGENT': 'legacy-browser' }
        expect(response.status).to eq(401)
      end
    end

    context 'with invalid session params' do
      it 'deletes session from cache on auth if params is wrong' do
        do_create_session_request
        expect(response.status).to eq(200)

        post auth_request, headers: { 'HTTP_USER_AGENT': 'legacy-browser' }

        expect(response.status).to eq(200)
        expect(response.headers['Authorization']).not_to be_nil
        expect(response.headers['Authorization']).to include "Bearer"

        post auth_request, headers: { 'HTTP_USER_AGENT': 'new-browser' }
        expect(response.status).to eq(401)

        post auth_request, headers: { 'HTTP_USER_AGENT': 'legacy-browser' }
        expect(response.status).to eq(401)
      end
    end
  end
end
