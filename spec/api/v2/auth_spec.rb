# frozen_string_literal: true

require 'spec_helper'

describe '/api/v2/auth functionality test' do
  let(:uri) { '/api/v2/identity/sessions' }
  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let!(:create_accountant_permission) do
    create :permission,
           role: 'accountant'
  end
  let!(:user) { create(:user) }
  let(:params) do
    {
      email: user.email,
      password: user.password
    }
  end
  let!(:create_permissions) do
    # optimize with %w[post get put head delete patch] each
    Permission.create(role: 'member', action: 'ACCEPT', verb: 'get', path: 'not_in_the_rules_path')
    Permission.create(role: 'member', action: 'ACCEPT', verb: 'head', path: 'not_in_the_rules_path')
    Permission.create(role: 'member', action: 'ACCEPT', verb: 'post', path: 'not_in_the_rules_path')
    Permission.create(role: 'member', action: 'ACCEPT', verb: 'put', path: 'not_in_the_rules_path')
    Permission.create(role: 'member', action: 'ACCEPT', verb: 'patch', path: 'not_in_the_rules_path')
    Permission.create(role: 'member', action: 'ACCEPT', verb: 'delete', path: 'not_in_the_rules_path')
    Permission.create(role: 'member', action: 'ACCEPT', verb: 'get', path: '/api/v2/resource/users/me')
  end

  let(:do_create_session_request) { post uri, params: params }
  let(:auth_request) { '/api/v2/auth/not_in_the_rules_path' }
  let(:protected_request) { '/api/v2/resource/users/me' }

  describe 'testing workability with session' do
    context 'with valid session' do
      before do
        Rails.cache.write('permissions', nil)
        do_create_session_request
      end

      it 'returns bearer token on valid session' do
        get auth_request

        expect(response.status).to eq(200)
        expect(response.headers['Authorization']).not_to be_nil
        expect(response.headers['Authorization']).to include "Bearer"
      end

      it "doesn't return set-cookie header on valid session" do
        get auth_request
        expect(response.status).to eq(200)
        expect(response.headers['Set-Cookie']).to be_nil
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

      it "doesn't return set-cookie header on invalid session" do
        get auth_request
        expect(response.status).to eq(401)
        expect(response.headers['Set-Cookie']).to be_nil
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
        Rails.cache.write('permissions', nil)
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
    let(:nonce) { Time.now.to_i }
    let(:kid) { api_key.kid }
    let(:secret) { SecureRandom.hex(16) }
    let(:data) { nonce.to_s + kid }
    let(:algorithm) { 'SHA' + api_key.algorithm[2..4]}
    let(:signature) { OpenSSL::HMAC.hexdigest(algorithm, secret, data) }

    before do
      Rails.cache.write('permissions', nil)
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
        expect(response.body).to eq("{\"errors\":[\"authz.invalid_session\"]}")
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
        expect(response.body).to eq("{\"errors\":[\"authz.disabled_2fa\"]}")
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

  describe 'testing rbac workability' do
    let!(:accountant_user) { create(:user, state: 'active', role: 'accountant') }
    let!(:admin_user) {create(:user, state: 'active', role: 'admin', otp: true) }
    let(:accountant_params) do { email: accountant_user.email, password: accountant_user.password } end
    let(:admin_params) do { email: admin_user.email, password: admin_user.password, otp_code: '1357' } end
    let(:do_create_session_request_acc) { post uri, params: accountant_params }
    let(:do_create_session_request_adm) { post uri, params: admin_params }

    let(:otp_enabled) { true }
    let!(:admin_api_key) { create :api_key, user: admin_user }

    let(:otp_code) { '1357' }
    let(:nonce) { Time.now.to_i }
    let(:adm_kid) { admin_api_key.kid }
    let(:secret) { SecureRandom.hex(16) }
    let(:adm_data) { nonce.to_s + adm_kid }
    let(:algorithm) { 'SHA' + admin_api_key.algorithm[2..4]}
    let(:signature) { OpenSSL::HMAC.hexdigest(algorithm, secret, adm_data) }

    let(:logger) { Logger.new('/dev/null') }
    let(:seeder) { Barong::Seed.new }
    let(:seeds) { { "permissions" => permissions } }

    let(:permissions) {
      [
        {
          "role" => "admin",
          "verb" => "get",
          "action" => "ACCEPT",
          "path" => "api/v2/admin/users/list"
        },
        {
          "role" => "accountant",
          "verb" => "post",
          "action" => "ACCEPT",
          "path" => "api/v2/accountant/documents"
        }
      ]
    }

    before do
      Rails.cache.write('permissions', nil)
      SecretStorage.store_secret(secret, admin_api_key.kid)
      allow(TOTPService).to receive(:validate?)
        .with(admin_user.uid, otp_code) { true }
      allow(SecretStorage).to receive(:get_secret)
        .with(adm_kid) { Vault::Secret.new(data: { value: secret }) }

      Permission.delete_all
      allow(seeder).to receive(:seeds).and_return(seeds)
      allow(seeder).to receive(:logger).and_return(logger)

      seeder.seed_permissions
    end

    context 'with cookies' do
      context 'not enough permissions' do
        it 'denies access for user with invalid cookies' do
          get auth_request
          expect(response.status).to eq(401)
          expect(response.body).to eq("{\"errors\":[\"authz.invalid_session\"]}")
        end

        it 'denies access for non-accountant user with valid cookies trying to GET accountant api' do
          do_create_session_request_adm

          get '/api/v2/auth/api/v2/accountant/documents'
          expect(response.status).to eq(401)
          expect(response.body).to eq("{\"errors\":[\"authz.invalid_permission\"]}")
          expect(response.headers['Authorization']).to be_nil
        end

        it 'denies POST for endpoint but allowing GET for admin user according to permissions' do
          do_create_session_request_adm

          post '/api/v2/auth/api/v2/admin/users/list'
          expect(response.status).to eq(401)
          expect(response.body).to eq("{\"errors\":[\"authz.invalid_permission\"]}")
          expect(response.headers['Authorization']).to be_nil

          get '/api/v2/auth/api/v2/admin/users/list'
          expect(response.status).to eq(200)
          expect(response.headers['Authorization']).not_to be_nil
          expect(response.headers['Authorization']).to include "Bearer"
        end

        it 'denies access because of the typo in the path' do
          do_create_session_request_adm
          get '/api/v2/auth/api/v2/admon/users/list'
          expect(response.status).to eq(401)
          expect(response.body).to eq("{\"errors\":[\"authz.invalid_permission\"]}")

          get '/api/v2/auth/api/v2/admin/users/list'
          expect(response.status).to eq(200)
          expect(response.headers['Authorization']).not_to be_nil
          expect(response.headers['Authorization']).to include "Bearer"
        end
      end

      context 'enough permissions' do
        it 'allowes access with for user with valid cookies, verb, role and path' do
          do_create_session_request_adm

          get '/api/v2/auth/api/v2/admin/users/list'
          expect(response.status).to eq(200)
          expect(response.headers['Authorization']).not_to be_nil
          expect(response.headers['Authorization']).to include "Bearer"

          do_create_session_request_acc
          post '/api/v2/auth/api/v2/accountant/documents'
          expect(response.status).to eq(200)
          expect(response.headers['Authorization']).not_to be_nil
          expect(response.headers['Authorization']).to include "Bearer"
        end
      end
    end

    context 'with api_keys' do
      context 'with valid api key headers' do
        context 'enough permissions' do
          it 'allowes access with for api key owner for valid verb, owner role and path' do
            get '/api/v2/auth/api/v2/admin/users/list', headers: {
              'X-Auth-Apikey' => adm_kid,
              'X-Auth-Nonce' => nonce,
              'X-Auth-Signature' => signature
            }

            expect(response.status).to eq(200)
            expect(response.headers['Authorization']).not_to be_nil
            expect(response.headers['Authorization']).to include "Bearer"
          end
        end

        context 'not enough permissions' do
          it 'denies access for non-accountant api key owner with valid cookies trying to GET accountant api' do
            post '/api/v2/auth/api/v2/accountant/documents', headers: {
              'X-Auth-Apikey' => adm_kid,
              'X-Auth-Nonce' => nonce,
              'X-Auth-Signature' => signature
            }

            expect(response.status).to eq(401)
            expect(response.body).to eq("{\"errors\":[\"authz.invalid_permission\"]}")
          end

          it 'denies POST for endpoint but allowing GET for api key owner according to permissions' do
            post '/api/v2/auth/api/v2/accountant/documents', headers: {
              'X-Auth-Apikey' => adm_kid,
              'X-Auth-Nonce' => nonce,
              'X-Auth-Signature' => signature
            }

            expect(response.status).to eq(401)
            expect(response.body).to eq("{\"errors\":[\"authz.invalid_permission\"]}")

            get '/api/v2/auth/api/v2/admin/users/list', headers: {
              'X-Auth-Apikey' => adm_kid,
              'X-Auth-Nonce' => nonce,
              'X-Auth-Signature' => signature
            }

            expect(response.status).to eq(200)
            expect(response.headers['Authorization']).not_to be_nil
            expect(response.headers['Authorization']).to include "Bearer"
          end
        end
      end
    end
  end
end
