# frozen_string_literal: true

require 'rails_helper'
require 'pry'

describe API::V2::Management::ServiceAccounts, type: :request do
  before do
    defaults_for_management_api_v2_security_configuration!
    management_api_v2_security_configuration.merge! \
      scopes: {
        read_service_accounts: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
        write_service_accounts: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
      }
  end
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let!(:create_service_account_permission) do
    create :permission,
           role: 'service_account'
  end
  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end

  let!(:user) { create(:user, role: 'member') }
  let!(:service_account) { create(:service_account, user: user) }

  describe 'Show service_account info' do
    let(:data) do
      {
        scope: :read_service_accounts
      }
    end

    let(:expected_attributes) do
      [:email, :uid, :role, :level, :state, :user, :created_at, :updated_at]
    end
    let(:signers) { %i[alex jeff] }

    let(:do_request) do
      post_json '/api/v2/management/service_accounts/get',
                multisig_jwt_management_api_v2({ data: data }, *signers)
    end

    it 'reads service_account info by uid' do
      data[:uid] = service_account.uid
      do_request

      expect(response.status).to eq 200
      expect(json_body.keys).to eq expected_attributes
    end

    it 'reads service_account info by email' do
      data[:email] = service_account.email
      do_request

      expect(response.status).to eq 200
      expect(json_body.keys).to eq expected_attributes
    end

    it 'denies when uid is not found' do
      data[:uid] = 'invalid'
      do_request
      expect(response.status).to eq 404
    end

    it 'denies when email is not found' do
      data[:email] = 'invalid'
      do_request
      expect(response.status).to eq 404
    end
  end


  describe 'Returns array of service accounts as collection' do
    let(:data) do
      {
        scope: :read_service_accounts
      }
    end
    let(:signers) { %i[alex jeff] }

    let(:do_request) do
      post_json '/api/v2/management/service_accounts/list',
                multisig_jwt_management_api_v2({ data: data }, *signers)
    end

    context 'service_accounts' do
      let!(:test_service_account) { create(:service_account, email: 'testa@gmail.com', user: user) }
      let!(:second_service_account) { create(:service_account, email: 'testb@gmail.com', user: user) }
      let!(:third_service_account) { create(:service_account, email: 'testd@gmail.com', user: user) }
      let!(:fourth_service_account) { create(:service_account, email: 'testc@gmail.com', user: user) }

      include_context 'bearer authentication'

      let(:do_service_accounts_request) do
        post_json '/api/v2/management/service_accounts/get',
                  multisig_jwt_management_api_v2({ data: data }), headers: auth_header
      end
      it 'denies access for user JWT instead of management signature' do
        do_service_accounts_request
        expect(response.status).to eq 401
      end

      it 'denies access unless enough signatures are supplied' do
        signers.clear.concat %i[james jeff]
        do_request
        expect(response.status).to eq 401
      end

      it 'returns list of service_accounts' do
        do_request

        service_accounts = JSON.parse(response.body)
        expect(ServiceAccount.count).to eq service_accounts.count
      end

      context 'pagination test' do
        let(:service_account_list_params) do
          {
            scope: :read_users,
            limit: 2
          }
        end

        it 'returns 1st page as default, limit 2 users per page' do
          service_account_list_params[:page] = 1
          post_json '/api/v2/management/service_accounts/list', multisig_jwt_management_api_v2({ data: service_account_list_params }, *signers), headers: auth_header

          expect(response.headers.fetch('Total')).to eq ServiceAccount.all.count.to_s
          expect(response.headers.fetch('Page')).to eq '1'
          expect(response.headers.fetch('Per-Page')).to eq '2'
        end

        it 'returns 2nd page, limit 2 users per page' do
          service_account_list_params[:page] = 2
          post_json '/api/v2/management/service_accounts/list', multisig_jwt_management_api_v2({ data: service_account_list_params }, *signers), headers: auth_header

          expect(response.headers.fetch('Total')).to eq ServiceAccount.all.count.to_s
          expect(response.headers.fetch('Page')).to eq '2'
          expect(response.headers.fetch('Per-Page')).to eq '2'
        end
      end
    end
  end

  describe 'Create a service account' do
    let(:signers) { %i[alex jeff] }
    let(:data) { params.merge(scope: :write_service_accounts) }

    let(:do_request) do
      post_json '/api/v2/management/service_accounts/create',
                multisig_jwt_management_api_v2({ data: data }, *signers)
    end

    context 'when uid is present' do
      context 'when email is valid' do
        let(:params) do
          {
            service_account_email: 'valid_email@example.com',
            service_account_uid: 'Fai5aesoLEcx',
            service_account_role: 'admin',
            owner_uid: user.uid
          }
        end

        it 'creates a service account' do
          expect { do_request }.to change { ServiceAccount.count }.by(1)
          expect_status_to_eq 201
        end
      end

      context 'when params are blank' do
        let(:params) { {} }

        it 'renders an error' do
          do_request
          expect_status_to_eq 422
          expect_body.to eq(error: 'owner_uid is missing, owner_uid is empty, service_account_role is missing, service_account_role is empty')
        end
      end

      context 'when email is bad' do
        let(:params) { { service_account_email: 'bad_email', service_account_uid: 'Fai5aesoLEcx', service_account_role: 'member', owner_uid: user.uid } }

        it 'renders an error' do
          expect { do_request }.to_not change { ServiceAccount.count }
          expect_status_to_eq 422
          expect_body.to eq(error: ['Email is invalid'])
        end
      end

      context 'when role does not exist' do
        let(:params) { { service_account_email: 'valid_email@example.com', service_account_uid: 'Fai5aesoLEcx', service_account_role: 'invalid', owner_uid: user.uid } }

        it 'renders an error' do
          expect { do_request }.to_not change { ServiceAccount.count }
          expect_status_to_eq 422
          expect_body.to eq(error: ['Role doesnt_exist'])
        end
      end

      context 'when uid is not uniq, the same as user one' do
        let(:params) { { service_account_email: 'valid_email@example.com', service_account_uid: user.uid, service_account_role: 'member', owner_uid: user.uid } }

        it 'renders an error' do
          expect { do_request }.to_not change { ServiceAccount.count }
          expect_status_to_eq 422
          expect(json_body[:error].first).to include 'Email or uid not_uniq'
        end
      end
    end
  end

  describe 'Delete a service account' do
    let(:signers) { %i[alex jeff] }
    let(:data) { params.merge(scope: :write_service_accounts) }

    let(:do_request) do
      post_json '/api/v2/management/service_accounts/delete',
                multisig_jwt_management_api_v2({ data: data }, *signers)
    end

    context do
      let(:params) { {uid: service_account.uid} }

      it do
        do_request
        expect_status_to_eq 200

        service_account = JSON.parse(response.body)
        expect(service_account['state']).to eq 'disabled'
      end
    end


    context 'when params are blank' do
      let(:params) { {} }

      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(error: 'uid is missing, uid is empty')
      end
    end
  end
end
