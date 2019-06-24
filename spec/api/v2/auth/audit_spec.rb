# frozen_string_literal: true

require 'spec_helper'

describe '/api/v2/auth functionality test' do
  before(:all) do
    create :permission, role: 'admin', action: 'AUDIT', verb: 'put', path: 'api/v2/admin/users'
    create :permission, role: 'member'
    create :permission, role: 'technical', action: 'AUDIT', verb: 'post', path: 'api/v2/admin/wallets'
    create :permission, role: 'accountant', action: 'AUDIT', verb: 'delete', path: 'api/v2/admin/markets'
    @user = create(:user)
    @accountant_user = create(:user, role: 'accountant')
    @admin_user = create(:user, role: 'admin')
    @technical_user = create(:user, role: 'technical')

    Permission.create(role: 'admin', action: 'ACCEPT', verb: 'get', path: 'api/v2/admin/users/list')
    Permission.create(role: 'accountant', action: 'ACCEPT', verb: 'post', path: 'api/v2/accountant/documents')
  end

  let(:uri) { '/api/v2/identity/sessions' }

  let(:do_create_session_request_acc) { post uri, params: { email: @accountant_user.email, password: @accountant_user.password }, headers: { 'HTTP_USER_AGENT' => 'random-browser' }}
  let(:do_create_session_request_adm) { post uri, params: { email: @admin_user.email, password: @admin_user.password, otp_code: '1357' }, headers: { 'HTTP_USER_AGENT' => 'random-browser' } }
  let(:do_create_session_request_tech) { post uri, params: { email: @technical_user.email, password: @technical_user.password }, headers: { 'HTTP_USER_AGENT' => 'random-browser' } }

  let(:do_create_session_request) { post uri, params: { email: @user.email, password: @user.password }, headers: { 'HTTP_USER_AGENT' => 'random-browser' } }
  let(:auth_request) { '/api/v2/auth/not_in_the_rules_path' }
  let(:protected_request) { '/api/v2/resource/users/me' }

  describe 'audit permissions testing' do
    let!(:turn_off_2fa) do
      User.all.each { |u| u.update(otp: false) }
    end
    let(:do_some_requests) do
      delete '/api/v2/auth/api/v2/admin', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
      post '/api/v2/auth/api/v2/admin', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
      put '/api/v2/auth/api/v2/admin', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
    end

    context 'records activity if path doesnt match with AUDIT permission path but matches with DROP or BLANK' do
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
          expect(Activity.where(category: 'admin', result: 'denied').count).to eq(3)

        end

        it 'for admin' do
          expect(Permission.all.count).to eq(0)
          # admin
          do_create_session_request_adm
          do_some_requests
          expect(Activity.where(category: 'admin', result: 'denied').count).to eq(3)
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
          expect(Activity.where(category: 'admin', result: 'denied').count).to eq(3)
        end

        it 'for admin' do
          # admin
          do_create_session_request_adm
          do_some_requests
          expect(response.status).to eq(401)
          expect(Activity.where(category: 'admin', result: 'denied').count).to eq(3)
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

        it 'works for general topic' do
          do_create_session_request_acc
          expect(Activity.where(category: 'admin').count).to eq(0)
          get '/api/v2/auth/api/v2/admin', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
          expect(Activity.where(category: 'admin').count).to eq(1)
          expect(Activity.last.topic).to eq('general')
          expect(Activity.last.result).to eq('denied')
        end

        it 'works for patch request' do
          do_create_session_request_acc
          expect(Activity.where(category: 'admin').count).to eq(0)
          patch '/api/v2/auth/api/v2/admin', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
          expect(Activity.where(category: 'admin').count).to eq(1)
          expect(Activity.last.topic).to eq('general')
          expect(Activity.last.action).to eq('update')
          expect(Activity.last.result).to eq('denied')
        end

        it 'works for non - put post patch get delete requests' do
          do_create_session_request_acc
          expect(Activity.where(category: 'admin').count).to eq(0)
          head '/api/v2/auth/api/v2/admin', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
          expect(Activity.where(category: 'admin').count).to eq(1)
          expect(Activity.last.topic).to eq('general')
          expect(Activity.last.action).to eq('system')
          expect(Activity.last.result).to eq('denied')
        end

        it 'for account role' do
          do_create_session_request_acc
          expect(Activity.where(category: 'admin').count).to eq(0)
          delete '/api/v2/auth/api/v2/admin/markets', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
          expect(Activity.where(category: 'admin').count).to eq(1)
          expect(Activity.last.topic).to eq('markets')
          expect(Activity.last.result).to eq('denied')
        end

        it 'for admin role' do
          do_create_session_request_adm
          expect(Activity.where(category: 'admin').count).to eq(0)
          put '/api/v2/auth/api/v2/admin/users', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
          expect(Activity.where(category: 'admin').count).to eq(1)
          expect(Activity.last.topic).to eq('users')
          expect(Activity.last.result).to eq('denied')
        end

        it 'for technical role' do
          do_create_session_request_tech
          expect(Activity.where(category: 'admin').count).to eq(0)
          post '/api/v2/auth/api/v2/admin/wallets', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
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
            expect(Activity.where(category: 'admin').count).to eq(1)
            expect(Activity.last.topic).to eq('accounting')
            expect(Activity.last.result).to eq('succeed')
          end

          it 'technical' do
            do_create_session_request_tech
            expect(Activity.where(category: 'admin').count).to eq(0)
            post '/api/v2/auth/api/v2/admin/wallets', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
            expect(Activity.where(category: 'admin').count).to eq(1)
            expect(Activity.last.topic).to eq('tech_support')
            expect(Activity.last.result).to eq('succeed')
          end

          it 'admin' do
            do_create_session_request_adm
            expect(Activity.where(category: 'admin').count).to eq(0)
            put '/api/v2/auth/api/v2/admin/users', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
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
          delete '/api/v2/auth/api/v2/admin/markets', params: { uid: @user.uid } ,headers: { 'HTTP_USER_AGENT' => 'random-browser' }
          expect(Activity.where(category: 'admin').count).to eq(1)
          expect(Activity.last.topic).to eq('markets')
          expect(Activity.last.result).to eq('denied')
        end

        it 'includes data in denied activity' do
          do_create_session_request_acc
          expect(Activity.where(category: 'admin').count).to eq(0)
          delete '/api/v2/auth/api/v2/admin/markets', headers: { 'HTTP_USER_AGENT' => 'random-browser' }, params: { user_uid: @user.uid }
          expect(Activity.where(category: 'admin').count).to eq(1)
          expect(Activity.last.topic).to eq('markets')
          expect(Activity.last.result).to eq('denied')
          expect(Activity.last.target_uid).to eq(@user.uid)
          expect(JSON.parse(Activity.last.data).keys).to include('user_uid', 'path', 'note')
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
            expect(Activity.where(category: 'admin').count).to eq(1)
            expect(Activity.last.topic).to eq('markets')
            expect(Activity.last.result).to eq('succeed')
          end

          it 'technical' do
            do_create_session_request_tech
            expect(Activity.where(category: 'admin').count).to eq(0)
            post '/api/v2/auth/api/v2/admin/wallets', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
            expect(Activity.where(category: 'admin').count).to eq(1)
            expect(Activity.last.topic).to eq('wallets')
            expect(Activity.last.result).to eq('succeed')
          end

          it 'admin' do
            do_create_session_request_adm
            expect(Activity.where(category: 'admin').count).to eq(0)
            put '/api/v2/auth/api/v2/admin/users', headers: { 'HTTP_USER_AGENT' => 'random-browser' }
            expect(Activity.where(category: 'admin').count).to eq(1)
            expect(Activity.last.topic).to eq('users')
            expect(Activity.last.result).to eq('succeed')
          end
        end

        context 'for different roles with user_uid in params' do
          it 'includes data in succesfull activity' do
            do_create_session_request_acc
            expect(Activity.where(category: 'admin').count).to eq(0)
            delete '/api/v2/auth/api/v2/admin/markets', headers: { 'HTTP_USER_AGENT' => 'random-browser' }, params: { user_uid: @user.uid }
            expect(Activity.where(category: 'admin').count).to eq(1)
            expect(Activity.last.topic).to eq('markets')
            expect(Activity.last.result).to eq('succeed')
            expect(Activity.last.target_uid).to eq(@user.uid)
            expect(JSON.parse(Activity.last.data).keys).to include('user_uid', 'path', 'note')
          end

          it 'create activity and save target_uid for accountant if user with this uid exists' do
            do_create_session_request_acc
            expect(Activity.where(category: 'admin').count).to eq(0)
            delete '/api/v2/auth/api/v2/admin/markets', headers: { 'HTTP_USER_AGENT' => 'random-browser' }, params: { user_uid: @user.uid }
            expect(Activity.where(category: 'admin').count).to eq(1)
            expect(Activity.last.topic).to eq('markets')
            expect(Activity.last.result).to eq('succeed')
            expect(Activity.last.target_uid).to eq(@user.uid)
          end
        end
      end
    end
  end
end
