# frozen_string_literal: true

require 'spec_helper'

describe '/api/v2/auth CSRF functionality test' do
  include_context 'geoip mock'

  before do
    allow_any_instance_of(Barong::Authorize).to receive(:validate_csrf!).and_call_original
  end
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
    context 'without CSRF token' do
      before do
        Rails.cache.delete('permissions')
        do_create_session_request
      end

      it 'doesnt return bearer token on valid session without CSRF' do
        post auth_request

        expect(response.status).to eq(401)
        expect(response.headers['Authorization']).to be_nil
        expect(response.body).to eq("{\"errors\":[\"authz.missing_csrf_token\"]}")
      end

      it 'works with any type of changing state verb request' do
        available_types = %w[post put delete patch]
        available_types.each do |ping|
          method("#{ping}").call auth_request

          expect(response.status).to eq(401)
          expect(response.headers['Authorization']).to be_nil
          expect(response.body).to eq("{\"errors\":[\"authz.missing_csrf_token\"]}")

          get protected_request, headers: { 'Authorization' => response.headers['Authorization'] }
          expect(response.status).to eq(401)
        end
      end

      it 'works without CSRF token on any type of safe verb request' do
        available_types = %w[get head]
        available_types.each do |ping|
          method("#{ping}").call auth_request

         expect(response.status).to eq(200)
          expect(response.headers['Authorization']).not_to be_nil

          get protected_request, headers: { 'Authorization' => response.headers['Authorization'] }
          expect(response.status).to eq(200)
        end
      end
    end

    context 'with CSRF token' do
      before do
        Rails.cache.delete('permissions')
        do_create_session_request
        @csrf = json_body[:csrf_token]
      end

      it 'doesnt return bearer token on valid session without CSRF' do
        get auth_request, headers: { 'X-CSRF-Token': @csrf }

        expect(response.status).to eq(200)
        expect(response.headers['Authorization']).not_to be_nil
      end

      it 'doesnt work on any type of request without csrf' do
        available_types = %w[post get put delete patch]
        available_types.each do |ping|
          method("#{ping}").call auth_request, headers: { 'X-CSRF-Token': @csrf }

          expect(response.status).to eq(200)
          expect(response.headers['Authorization']).not_to be_nil

          get protected_request, headers: { 'Authorization' => response.headers['Authorization'] }
          expect(response.status).to eq(200)
        end
      end
    end
  end

  describe 'testing workability with api keys' do
    let!(:test_user) { create(:user, otp: otp_enabled) }
    let(:otp_enabled) { true }
    let!(:api_key) { create :api_key, key_holder_account: test_user }
    let(:otp_code) { '1357' }
    let(:nonce) { (Time.now.to_f * 1000).to_i }
    let(:kid) { api_key.kid }
    let(:secret) { api_key.secret }
    let(:data) { nonce.to_s + kid }
    let(:algorithm) { 'SHA' + api_key.algorithm[2..4]}
    let(:signature) { OpenSSL::HMAC.hexdigest(algorithm, secret, data) }

    before do
      Rails.cache.delete('permissions')
      SecretStorage.store_secret(secret, api_key.kid)
      allow(TOTPService).to receive(:validate?)
        .with(test_user.uid, otp_code) { true }
    end

    context 'with valid api keys' do
      it 'works without CSRF' do
        get auth_request, headers: {
          'X-Auth-Apikey' => kid,
          'X-Auth-Nonce' => nonce,
          'X-Auth-Signature' => signature
        }
        expect(response.status).to eq(200)
        expect(response.body).to be_empty
        expect(response.headers['Authorization']).to include 'Bearer'
        expect(response.headers['Authorization']).not_to be_nil

        get protected_request, headers: { 'Authorization' => response.headers['Authorization'] }
        expect(response.status).to eq(200)
      end
    end
  end
end
