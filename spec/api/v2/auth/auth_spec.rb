# frozen_string_literal: true

require 'spec_helper'

describe '/api/v2/auth functionality test' do
  include_context 'geoip mock'

  let(:uri) { '/api/v2/identity/sessions' }
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

  let(:do_create_session_request) { post uri, params: params }
  let(:auth_request) { '/api/v2/auth/not_in_the_rules_path' }
  let(:protected_request) { '/api/v2/resource/users/me' }

  describe 'testing workability with session' do
    context 'with valid session' do
      before do
        Rails.cache.delete('permissions')
        do_create_session_request
      end

      it 'returns bearer token on valid session' do
        get auth_request

        expect(response.status).to eq(200)
        expect(response.headers['Authorization']).not_to be_nil
        expect(response.headers['Authorization']).to include "Bearer"
      end

      it 'allows any type of request' do
        available_types = %w[post get put head delete patch]
        available_types.each do |ping|
          method("#{ping}").call auth_request

          expect(response.headers['Authorization']).not_to be_nil

          get protected_request, headers: { 'Authorization' => response.headers['Authorization'] }
          expect(response.status).to eq(200)
        end
      end
    end

    context 'testing session related errors' do
      it 'renders error if no session or api key headers provided' do
        get auth_request
        expect(response.status).to eq(401)
        expect(response.body).to eq("{\"errors\":[\"authz.invalid_session\"]}")
      end

      it 'renders error if session belongs to non-active user' do
        do_create_session_request
        expect(response.status).to eq(200)
        user.update(state: 'banned')

        get auth_request
        expect(response.status).to eq(401)
        expect(response.body).to eq("{\"errors\":[\"authz.user_not_active\"]}")
      end
    end

    context 'testing restrictions' do
      before do
        Rails.cache.delete('permissions')
        do_create_session_request
        expect(response.status).to eq(200)
      end

      let(:do_restricted_request) { put '/api/v2/auth/api/v2/peatio/management/ping' }

      it 'receives access error if path is blacklisted' do
        do_restricted_request
        expect(response.status).to eq(401)
        expect(response.body).to eq("{\"errors\":[\"authz.permission_denied\"]}")
      end

      let(:do_whitelisted_request) { put '/api/v2/auth/api/v2/peatio/public/ping' }

      it 'receives access error if path is blacklisted' do
        do_whitelisted_request
        expect(response.status).to eq(200)
        expect(response.body).to be_empty
        expect(response.headers['Authorization']).to be_nil
      end
    end
  end

  describe 'testing workability with api keys' do
    include_context 'bearer authentication'
    let!(:test_user) { create(:user, otp: otp_enabled) }
    let(:otp_enabled) { true }
    let!(:api_key) { create :api_key, user: test_user }
    let(:otp_code) { '1357' }
    let(:nonce) { (Time.now.to_f * 1000).to_i }
    let(:kid) { api_key.kid }
    let(:secret) { SecureRandom.hex(16) }
    let(:data) { nonce.to_s + kid }
    let(:algorithm) { 'SHA' + api_key.algorithm[2..4]}
    let(:signature) { OpenSSL::HMAC.hexdigest(algorithm, secret, data) }

    before do
      Rails.cache.delete('permissions')
      SecretStorage.store_secret(secret, api_key.kid)
      allow(TOTPService).to receive(:validate?)
        .with(test_user.uid, otp_code) { true }
      allow(SecretStorage).to receive(:get_secret)
        .with(kid) { Vault::Secret.new(data: { value: secret }) }
    end

    context 'testing api key related errors' do
      it 'catches api key headers and renders error on missing header' do
        get auth_request, headers: {
          'X-Auth-Apikey' => kid,
          'X-Auth-Nonce' => nonce,
        }
        expect(response.status).to eq(422)
        expect(response.body).to eq("{\"errors\":[\"authz.invalid_api_key_headers\"]}")
        expect(response.headers['Authorization']).to be_nil
      end

      it 'catches api key headers and renders error if nonce is string' do
        get auth_request, headers: {
          'X-Auth-Apikey' => kid,
          'X-Auth-Nonce' => 'nonce',
          'X-Auth-Signature' => signature
        }
        expect(response.status).to eq(401)
        expect(response.body).to eq("{\"errors\":[\"authz.nonce_not_valid_timestamp\"]}")
        expect(response.headers['Authorization']).to be_nil
      end

      it 'catches api key headers and renders error if nonce is zero' do
        get auth_request, headers: {
          'X-Auth-Apikey' => kid,
          'X-Auth-Nonce' => 0,
          'X-Auth-Signature' => signature
        }
        expect(response.status).to eq(401)
        expect(response.body).to eq("{\"errors\":[\"authz.nonce_not_valid_timestamp\"]}")
        expect(response.headers['Authorization']).to be_nil
      end

      it 'catches api key headers and renders error if nonce is older than default 5 seconds' do
        get auth_request, headers: {
          'X-Auth-Apikey' => kid,
          'X-Auth-Nonce' => ((Time.now - 10.seconds).to_f * 1000).to_i,
          'X-Auth-Signature' => signature
        }
        expect(response.status).to eq(401)
        expect(response.body).to eq("{\"errors\":[\"authz.nonce_expired\"]}")
        expect(response.headers['Authorization']).to be_nil
      end

      it 'catches api key headers and renders error if nonce is from future' do
        get auth_request, headers: {
          'X-Auth-Apikey' => kid,
          'X-Auth-Nonce' => ((Time.now + 10.seconds).to_f * 1000).to_i,
          'X-Auth-Signature' => signature
        }
        expect(response.status).to eq(401)
        expect(response.body).to eq("{\"errors\":[\"authz.nonce_from_future\"]}")
        expect(response.headers['Authorization']).to be_nil
      end

      it 'catches api key headers and renders error if nonce is using twice' do
        get auth_request, headers: {
          'X-Auth-Apikey' => kid,
          'X-Auth-Nonce' => nonce,
          'X-Auth-Signature' => signature
        }
        expect(response.status).to eq(200)
        expect(response.body).to be_empty
        expect(response.headers['Authorization']).to include "Bearer"
        expect(response.headers['Authorization']).not_to be_nil

        get auth_request, headers: {
          'X-Auth-Apikey' => kid,
          'X-Auth-Nonce' => nonce,
          'X-Auth-Signature' => signature
        }
        expect(response.status).to eq(401)
        expect(response.body).to eq("{\"errors\":[\"authz.signature_blacklisted\"]}")
        expect(response.headers['Authorization']).to be_nil
      end

      it 'catches api key headers and renders error on blank header' do
        get auth_request, headers: {
          'X-Auth-Apikey' => kid,
          'X-Auth-Nonce' => nonce,
          'X-Auth-Signature' => ' '
        }
        expect(response.status).to eq(422)
        expect(response.body).to eq("{\"errors\":[\"authz.invalid_api_key_headers\"]}")
        expect(response.headers['Authorization']).to be_nil
      end

      it 'renders error when signature is invalid' do
        get auth_request, headers: {
          'X-Auth-Apikey' => kid,
          'X-Auth-Nonce' => nonce,
          'X-Auth-Signature' => 'some-random-signature'
        }
        expect(response.status).to eq(401)
        expect(response.body).to eq("{\"errors\":[\"authz.invalid_signature\"]}")
        expect(response.headers['Authorization']).to be_nil
      end

      let(:ban_api_key) { APIKey.last.update(state: 'banned') }

      it 'renders error when api key state is not active' do
        ban_api_key
        get auth_request, headers: {
          'X-Auth-Apikey' => kid,
          'X-Auth-Nonce' => nonce,
          'X-Auth-Signature' => signature
        }
        expect(response.status).to eq(401)
        expect(response.body).to eq("{\"errors\":[\"authz.apikey_not_active\"]}")
        expect(response.headers['Authorization']).to be_nil
      end

      let(:ban_user) { test_user.update(state: 'banned') }

      it 'renders error when api key state is not active' do
        ban_user
        get auth_request, headers: {
          'X-Auth-Apikey' => kid,
          'X-Auth-Nonce' => nonce,
          'X-Auth-Signature' => signature
        }
        expect(response.status).to eq(401)
        expect(response.body).to eq("{\"errors\":[\"authz.apikey_not_active\"]}")
        expect(response.headers['Authorization']).to be_nil
      end

      let(:disable_user_2fa) { test_user.update(otp: false) }

      it 'renders error when api key is valid but user have disabled 2fa' do
        disable_user_2fa
        get auth_request, headers: {
          'X-Auth-Apikey' => kid,
          'X-Auth-Nonce' => nonce,
          'X-Auth-Signature' => signature
        }

        expect(response.status).to eq(401)
        expect(response.body).to eq("{\"errors\":[\"authz.apikey_not_active\"]}")
        expect(response.headers['Authorization']).to be_nil
      end
    end

    context 'testing api key with valid params' do
      it 'catches api key headers and renders error on blank header' do
        get auth_request, headers: {
          'X-Auth-Apikey' => kid,
          'X-Auth-Nonce' => nonce,
          'X-Auth-Signature' => signature
        }
        expect(response.status).to eq(200)
        expect(response.body).to be_empty
        expect(response.headers['Authorization']).to include "Bearer"
        expect(response.headers['Authorization']).not_to be_nil

        get protected_request, headers: { 'Authorization' => response.headers['Authorization'] }
        expect(response.status).to eq(200)
      end
    end

    context 'testing restrictions' do
      let(:do_restricted_request) {
        put '/api/v2/auth/api/v2/peatio/management/ping', headers: {
          'X-Auth-Apikey' => kid,
          'X-Auth-Nonce' => nonce,
          'X-Auth-Signature' => signature
        }
      }

      it 'receives access error if path is blacklisted' do
        do_restricted_request
        expect(response.status).to eq(401)
        expect(response.body).to eq("{\"errors\":[\"authz.permission_denied\"]}")
      end

      let(:do_whitelisted_request) {
        put '/api/v2/auth/api/v2/peatio/public/ping', headers: {
          'X-Auth-Apikey' => kid,
          'X-Auth-Nonce' => nonce,
          'X-Auth-Signature' => signature
        }
      }

      it 'receives access error if path is whitelisted' do
        do_whitelisted_request
        expect(response.status).to eq(200)
        expect(response.body).to be_empty
        expect(response.headers['Authorization']).to be_nil
      end
    end
  end
end
