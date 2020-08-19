# frozen_string_literal: true

require 'spec_helper'

describe '/api/v2/auth functionality test' do
  include_context 'geoip mock'

  let(:do_protected_request) { get '/api/v2/auth/api/v2/resource/users/me' }

  describe 'testing rbac workability' do
    before(:example) do
      Thread.list.last.kill if Thread.list.last.to_s.include?('activity')
    end
    let!(:create_permissions) do
      Permission.create(role: 'superadmin', action: 'ACCEPT', verb: 'get', path: 'api/v2/admin/users/list')
      Rails.cache.delete('permissions')
      @admin = User.create(email: 'superadmin@admin.io', password: 'Tecohvi0', role: 'superadmin', state: 'active')
    end

    context 'with cookies' do
      let(:do_create_session_request_superadm) { post  '/api/v2/identity/sessions', params: { email: 'superadmin@admin.io', password: 'Tecohvi0' }}

      context 'not enough permissions' do
        it 'denies access for user with missing cookies' do
          do_protected_request
          expect(response.status).to eq(401)
          expect(response.body).to eq("{\"errors\":[\"authz.invalid_session\"]}")
        end

        it 'denies access for non-accountant user with valid cookies trying to GET accountant api' do
          do_create_session_request_superadm

          get '/api/v2/auth/api/v2/accountant/documents'

          expect(response.status).to eq(401)
          expect(response.body).to eq("{\"errors\":[\"authz.invalid_permission\"]}")
          expect(response.headers['Authorization']).to be_nil
        end

        it 'denies POST for endpoint but allowing GET for admin user according to permissions' do
          do_create_session_request_superadm

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
          do_create_session_request_superadm
          get '/api/v2/auth/api/v2/admon/users/list'
          expect(response.status).to eq(401)
          expect(response.body).to eq("{\"errors\":[\"authz.invalid_permission\"]}")
        end
      end

      context 'enough permissions' do
        it 'allowes access with for user with valid cookies, verb, role and path' do
          do_create_session_request_superadm

          get '/api/v2/auth/api/v2/admin/users/list'
          expect(response.status).to eq(200)
          expect(response.headers['Authorization']).not_to be_nil
          expect(response.headers['Authorization']).to include "Bearer"
        end
      end
    end

    context 'with api_keys' do
      let!(:admin_api_key) { create :api_key, key_holder_account: @admin }
      let(:nonce) { (Time.now.to_f * 1000).to_i }
      let(:secret) { admin_api_key.secret }
      let(:signature) { OpenSSL::HMAC.hexdigest('SHA256', secret, nonce.to_s + admin_api_key.kid ) }
      let!(:turn_on_2fa) { @admin.update(otp: true) }

      context 'with valid api key headers' do
        context 'enough permissions' do
          it 'allowes access with for api key owner for valid verb, owner role and path' do
            allow(TOTPService).to receive(:validate?)
              .with(@admin.uid, '1357') { true }

            get '/api/v2/auth/api/v2/admin/users/list', headers: {
              'X-Auth-Apikey' => admin_api_key.kid,
              'X-Auth-Nonce' => nonce,
              'X-Auth-Signature' => signature
            }
            expect(response.status).to eq(200)

            expect(response.headers['Authorization']).not_to be_nil
            expect(response.headers['Authorization']).to include "Bearer"
          end
        end

        context 'not enough permissions' do
          it 'denies access for non-accountant api key owner with valid api_key trying to POST accountant api' do
           allow(TOTPService).to receive(:validate?)
             .with(@admin.uid, '1357') { true }
           allow(SecretStorage).to receive(:get_secret)
             .with(admin_api_key.kid) { Vault::Secret.new(data: { value: secret }) }

            post '/api/v2/auth/api/v2/accountant/documents', headers: {
              'X-Auth-Apikey' => admin_api_key.kid,
              'X-Auth-Nonce' => nonce,
              'X-Auth-Signature' => signature
            }
            expect(response.status).to eq(401)
            expect(response.body).to eq("{\"errors\":[\"authz.invalid_permission\"]}")
          end

          it 'denies POST for endpoint but allowing GET for api key owner according to permissions' do
            allow(TOTPService).to receive(:validate?)
              .with(@admin.uid, '1357') { true }
            allow(SecretStorage).to receive(:get_secret)
              .with(admin_api_key.kid) { Vault::Secret.new(data: { value: secret }) }

              post '/api/v2/auth/api/v2/accountant/documents', headers: {
                'X-Auth-Apikey' => admin_api_key.kid,
                'X-Auth-Nonce' => nonce,
                'X-Auth-Signature' => signature
              }
              Rails.cache.delete(admin_api_key.kid)
              expect(response.status).to eq(401)
              expect(response.body).to eq("{\"errors\":[\"authz.invalid_permission\"]}")

              get '/api/v2/auth/api/v2/admin/users/list', headers: {
                'X-Auth-Apikey' => admin_api_key.kid,
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
