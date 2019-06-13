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

  let(:do_create_session_request) { post uri, params: params, headers: { 'HTTP_USER_AGENT' => 'random-browser' } }
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

  let!(:create_audit_permissions) do
    Permission.create(role: 'technical', action: 'AUDIT', verb: 'post', path: 'api/v2/admin/wallets')
    Permission.create(role: 'admin', action: 'AUDIT', verb: 'put', path: 'api/v2/admin/users')
    Permission.create(role: 'accountant', action: 'AUDIT', verb: 'delete', path: 'api/v2/admin/markets')
  end
  let!(:accountant_user) { create(:user, role: 'accountant') }
  let!(:admin_user) { create(:user, role: 'admin') }
  let!(:technical_user) { create(:user, role: 'technical') }

  let(:do_create_session_request_acc) { post uri, params: accountant_params, headers: { 'HTTP_USER_AGENT' => 'random-browser' }}
  let(:do_create_session_request_adm) { post uri, params: admin_params, headers: { 'HTTP_USER_AGENT' => 'random-browser' } }
  let(:do_create_session_request_tech) { post uri, params: technical_params, headers: { 'HTTP_USER_AGENT' => 'random-browser' } }

  let(:accountant_params) { { email: accountant_user.email, password: accountant_user.password } }
  let(:admin_params) { { email: admin_user.email, password: admin_user.password, otp_code: '1357' } }
  let(:technical_params) { { email: technical_user.email, password: technical_user.password } }

  describe 'testing rbac workability' do
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
      let!(:turn_on_2fa) do
        User.all.each { |u| u.update(otp: true) }
      end

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

  describe 'audit permissions testing' do
    let!(:turn_off_2fa) do
      User.all.each { |u| u.update(otp: false) }
    end
    let(:do_some_requests) do
      delete '/api/v2/auth/api/v2/admin', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
      post '/api/v2/auth/api/v2/admin', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
      put '/api/v2/auth/api/v2/admin', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
    end

    context 'doesnt record activity if path doesnt match with AUDIT permission path' do
      context 'acts as expected with different roles with another permission type match' do
        before do
          Permission.delete_all
          Rails.cache.write('permissions', nil)
        end

        it 'for accountant' do
          expect(Permission.all.count).to eq(0)
          # accountant
          do_create_session_request_acc
          do_some_requests
          expect(Activity.where(category: 'admin').count).to eq(0)
        end

        it 'for admin' do
          expect(Permission.all.count).to eq(0)
          # admin
          do_create_session_request_adm
          do_some_requests
          expect(Activity.where(category: 'admin').count).to eq(0)
        end
      end

      context 'acts as expected with different roles without any permissions' do
        before do
          Permission.delete_all
          Rails.cache.write('permissions', nil)
          expect(Permission.all.count).to eq(0)
        end

        it 'for accountant' do
          # accountant
          do_create_session_request_acc
          do_some_requests
          expect(response.status).to eq(401)
          expect(Activity.where(category: 'admin').count).to eq(0)
        end

        it 'for admin' do
          # admin
          do_create_session_request_adm
          do_some_requests
          expect(response.status).to eq(401)
          expect(Activity.where(category: 'admin').count).to eq(0)
        end
      end
    end

    context 'records failed activity if path matches with AUDIT permission path' do
      context 'creates only one thread' do
        before do
          Permission.delete_all
          Permission.create(role: 'technical', action: 'AUDIT', verb: 'post', path: 'api/v2/admin/wallets')
          Permission.create(role: 'admin', action: 'AUDIT', verb: 'put', path: 'api/v2/admin/users')
          Permission.create(role: 'accountant', action: 'AUDIT', verb: 'delete', path: 'api/v2/admin/markets')
          Rails.cache.write('permissions', nil)
        end
      end

      context 'without topic specified and without user_uid in params' do
        let!(:create_audit_permissions) do
          Permission.create(role: 'technical', action: 'AUDIT', verb: 'post', path: 'api/v2/admin/wallets')
          Permission.create(role: 'admin', action: 'AUDIT', verb: 'put', path: 'api/v2/admin/users')
          Permission.create(role: 'accountant', action: 'AUDIT', verb: 'delete', path: 'api/v2/admin/markets')
          Rails.cache.write('permissions', nil)
        end
        it 'for account role' do
          do_create_session_request_acc
          expect(Activity.where(category: 'admin').count).to eq(0)
          delete '/api/v2/auth/api/v2/admin/markets', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
          sleep 0.01
          expect(Activity.where(category: 'admin').count).to eq(1)
          expect(Activity.last.topic).to eq('markets')
          expect(Activity.last.result).to eq('denied')
        end

        it 'for admin role' do
          do_create_session_request_adm
          expect(Activity.where(category: 'admin').count).to eq(0)
          put '/api/v2/auth/api/v2/admin/users', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
          sleep 0.01
          expect(Activity.where(category: 'admin').count).to eq(1)
          expect(Activity.last.topic).to eq('users')
          expect(Activity.last.result).to eq('denied')
        end

        it 'for technical role' do
          do_create_session_request_tech
          expect(Activity.where(category: 'admin').count).to eq(0)
          post '/api/v2/auth/api/v2/admin/wallets', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
          sleep 0.01
          expect(Activity.where(category: 'admin').count).to eq(1)
          expect(Activity.last.topic).to eq('wallets')
          expect(Activity.last.result).to eq('denied')
        end
      end

      context 'with specified topic and without user_uid' do
        let!(:create_audit_permissions) do
          Permission.delete_all
          Permission.create(role: 'technical', action: 'ACCEPT', verb: 'post', path: 'api/v2/admin/wallets', topic: 'tech_support')
          Permission.create(role: 'admin', action: 'ACCEPT', verb: 'put', path: 'api/v2/admin/users', topic: 'administrating')
          Permission.create(role: 'accountant', action: 'ACCEPT', verb: 'delete', path: 'api/v2/admin/markets', topic: 'accounting')

          Permission.create(role: 'technical', action: 'AUDIT', verb: 'post', path: 'api/v2/admin/wallets', topic: 'tech_support')
          Permission.create(role: 'admin', action: 'AUDIT', verb: 'put', path: 'api/v2/admin/users', topic: 'administrating')
          Permission.create(role: 'accountant', action: 'AUDIT', verb: 'delete', path: 'api/v2/admin/markets', topic: 'accounting')
          Rails.cache.write('permissions', nil)
        end
        context 'for different roles' do
          it 'accountant' do
            do_create_session_request_acc
            expect(Activity.where(category: 'admin').count).to eq(0)
            delete '/api/v2/auth/api/v2/admin/markets', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
            sleep 0.01
            expect(Activity.where(category: 'admin').count).to eq(1)
            expect(Activity.last.topic).to eq('accounting')
            expect(Activity.last.result).to eq('succeed')
          end

          it 'technical' do
            do_create_session_request_tech
            expect(Activity.where(category: 'admin').count).to eq(0)
            post '/api/v2/auth/api/v2/admin/wallets', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
            sleep 0.01
            expect(Activity.where(category: 'admin').count).to eq(1)
            expect(Activity.last.topic).to eq('tech_support')
            expect(Activity.last.result).to eq('succeed')
          end

          it 'admin' do
            do_create_session_request_adm
            expect(Activity.where(category: 'admin').count).to eq(0)
            put '/api/v2/auth/api/v2/admin/users', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
            sleep 0.01
            expect(Activity.where(category: 'admin').count).to eq(1)
            expect(Activity.last.topic).to eq('administrating')
            expect(Activity.last.result).to eq('succeed')
          end
        end
      end

      context 'with specified topic and user_uid' do
        let!(:create_audit_permissions) do
          Permission.create(role: 'technical', action: 'AUDIT', verb: 'post', path: 'api/v2/admin/wallets', topic: 'tech_support')
          Permission.create(role: 'admin', action: 'AUDIT', verb: 'put', path: 'api/v2/admin/users', topic: 'administrating')
          Permission.create(role: 'accountant', action: 'AUDIT', verb: 'delete', path: 'api/v2/admin/markets', topic: 'accounting')
          Rails.cache.write('permissions', nil)
        end

        it 'for different roles' do
          do_create_session_request_acc
          expect(Activity.where(category: 'admin').count).to eq(0)
          delete '/api/v2/auth/api/v2/admin/markets', params: { uid: user.uid } ,headers: { 'HTTP_USER_AGENT' => 'random-browser' }
          sleep 0.01
          expect(Activity.where(category: 'admin').count).to eq(1)
          expect(Activity.last.topic).to eq('markets')
          expect(Activity.last.result).to eq('denied')
        end
      end
    end

    context 'records succesfull activity if path matches with AUDIT permission path' do
      context 'with different params combination' do
        let!(:create_audit_permissions) do
          Permission.create(role: 'accountant', action: 'ACCEPT', verb: 'delete', path: 'api/v2/admin/markets')
          Permission.create(role: 'admin', action: 'ACCEPT', verb: 'put', path: 'api/v2/admin/users')
          Permission.create(role: 'technical', action: 'ACCEPT', verb: 'post', path: 'api/v2/admin/wallets')
          Permission.create(role: 'technical', action: 'AUDIT', verb: 'post', path: 'api/v2/admin/wallets')
          Permission.create(role: 'admin', action: 'AUDIT', verb: 'put', path: 'api/v2/admin/users')
          Permission.create(role: 'accountant', action: 'AUDIT', verb: 'delete', path: 'api/v2/admin/markets')
          Rails.cache.write('permissions', nil)
        end

        context 'for different roles without params' do
          it 'accountant' do
            do_create_session_request_acc
            expect(Activity.where(category: 'admin').count).to eq(0)
            delete '/api/v2/auth/api/v2/admin/markets', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
            sleep 0.01
            expect(Activity.where(category: 'admin').count).to eq(1)
            expect(Activity.last.topic).to eq('markets')
            expect(Activity.last.result).to eq('succeed')
          end

          it 'technical' do
            do_create_session_request_tech
            expect(Activity.where(category: 'admin').count).to eq(0)
            post '/api/v2/auth/api/v2/admin/wallets', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
            sleep 0.01
            expect(Activity.where(category: 'admin').count).to eq(1)
            expect(Activity.last.topic).to eq('wallets')
            expect(Activity.last.result).to eq('succeed')
          end

          it 'admin' do
            do_create_session_request_adm
            expect(Activity.where(category: 'admin').count).to eq(0)
            put '/api/v2/auth/api/v2/admin/users', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
            sleep 0.01
            expect(Activity.where(category: 'admin').count).to eq(1)
            expect(Activity.last.topic).to eq('users')
            expect(Activity.last.result).to eq('succeed')
          end
        end

        context 'for different roles with user_uid in params' do
          it 'create activity and save target_uid for accountant if user with this uid exists' do
            do_create_session_request_acc
            expect(Activity.where(category: 'admin').count).to eq(0)
            delete '/api/v2/auth/api/v2/admin/markets', headers: { 'HTTP_USER_AGENT' => 'random-browser' }, params: { user_uid: user.uid }
            sleep 0.01

            expect(Activity.where(category: 'admin').count).to eq(1)
            expect(Activity.last.topic).to eq('markets')
            expect(Activity.last.result).to eq('succeed')
            expect(Activity.last.target_uid).to eq(user.uid)
          end

          it 'doesnt create activity and save target_uid for accountant cause user with this uid doesnt exist' do
            do_create_session_request_acc
            expect(Activity.where(category: 'admin').count).to eq(0)
            delete '/api/v2/auth/api/v2/admin/markets', headers: { 'HTTP_USER_AGENT' => 'random-browser' }, params: { user_uid: 'ID0000' }
            sleep 0.01
            expect(Activity.where(category: 'admin').count).to eq(0)
          end
        end
      end
    end
  end
end
