# frozen_string_literal: true

describe API::V2::Management::APIKeys, type: :request do
  before do
    defaults_for_management_api_v2_security_configuration!
    management_api_v2_security_configuration.merge! \
      scopes: {
        write_apikeys: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
      }
  end

  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end

  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end

  let!(:create_service_account_permission) do
    create :permission,
           role: 'service_account'
  end

 describe 'POST /api_keys' do
    let(:signers) { %i[alex jeff] }
    let(:data) { params.merge(scope: :write_apikeys) }

    let(:do_request) do
      post_json '/api/v2/management/api_keys',
                multisig_jwt_management_api_v2({ data: data }, *signers)
    end

    let(:params) do
      api_keys_params
    end

    context 'valid request' do
      context 'service account' do
        before do
          allow(Barong::App.config).to receive_messages(mgn_api_keys_sa: true)
        end

        let!(:service_account) { create(:service_account) }

        let(:api_keys_params) do
          {
            uid: service_account.uid,
            algorithm: 'HS256',
            scopes: 'trade'
          }
        end

        it 'creates a api key' do
          do_request
          expect(response.status).to eq(201)

          result = JSON.parse(response.body)
          expect(result.keys).to match_array %w[kid algorithm scope state secret created_at updated_at]
          expect(result['state']).to eq service_account.state
          expect(result['scope']).to eq ['trade']
          expect(result['algorithm']).to eq 'HS256'
        end
      end

      context 'user' do
        before do
          allow(Barong::App.config).to receive_messages(mgn_api_keys_user: true)
        end

        let!(:user) { create(:user) }

        let(:api_keys_params) do
          {
            uid: user.uid,
            algorithm: 'HS256',
            scopes: 'trade'
          }
        end

        it 'creates a api key' do
          do_request
          expect(response.status).to eq(201)

          result = JSON.parse(response.body)
          expect(result.keys).to match_array %w[kid algorithm scope state secret created_at updated_at]
          expect(result['state']).to eq user.state
          expect(result['scope']).to eq ['trade']
          expect(result['algorithm']).to eq 'HS256'
        end
      end
    end

    context 'invalid request' do
      context 'vault inaccessible' do
        before do
          allow(Barong::App.config).to receive_messages(mgn_api_keys_sa: true)
        end

        let!(:service_account) { create(:service_account) }
        let(:api_keys_params) do
          {
            uid: service_account.uid,
            algorithm: 'HS256',
            scopes: 'trade'
          }
        end

        it 'should raise an error' do
          allow(Vault::Rails).to receive(:encrypt).and_raise(Vault::VaultError)
          do_request
          expect(response.status).to eq(422)
          expect_body.to eq(errors: ["api_key.could_not_save_secret"])
        end
      end

      context 'service account doesnt exist' do
        before do
          allow(Barong::App.config).to receive_messages(mgn_api_keys_sa: true)
        end

        let(:api_keys_params) do
          {
            uid: ServiceAccount::UID_PREFIX + 'random',
            algorithm: 'HS256',
            scopes: 'trade'
          }
        end

        it 'should raise an error' do
          do_request
          expect(response.status).to eq(422)
          expect_body.to eq(error: 'service_account_doesnt_exist')
        end
      end

      context 'user doesnt exists' do
        before do
          allow(Barong::App.config).to receive_messages(mgn_api_keys_user: true)
        end

        let(:api_keys_params) do
          {
            uid: UIDGenerator.generate(Barong::App.config.uid_prefix),
            algorithm: 'HS256',
            scopes: 'trade'
          }
        end

        it 'should raise an error' do
          do_request
          expect(response.status).to eq(422)
          expect_body.to eq(error: 'user_doesnt_exist')
        end
      end

      context 'algorithm is invalid' do
        before do
          allow(Barong::App.config).to receive_messages(mgn_api_keys_sa: true)
        end

        let!(:service_account) { create(:service_account) }
        let(:api_keys_params) do
          {
            uid: service_account.uid,
            algorithm: 'random',
            scopes: 'trade'
          }
        end

        it 'should raise an error' do
          do_request
          expect(response.status).to eq(422)
          expect_body.to eq(errors: ['kid.blank', 'algorithm.inclusion'])
        end
      end

      context 'disabled endpoint' do
        let(:api_keys_params) do
          {
            uid: UIDGenerator.generate(Barong::App.config.uid_prefix),
            algorithm: 'HS256',
            scopes: 'trade'
          }
        end

        it 'should raise an error' do
          do_request
          expect(response.status).to eq(422)
          expect_body.to eq(error: 'disabled_management_endpoint')
        end
      end

      context 'unexisting uid' do

        let(:api_keys_params) do
          {
            uid: 'random',
            algorithm: 'HS256',
            scopes: 'trade'
          }
        end

        it 'should raise an error' do
          do_request
          expect(response.status).to eq(422)
          expect_body.to eq(error: 'uid_prefix_doesnt_exist')
        end
      end
    end
  end

  describe 'POST /api_keys/update' do
    let(:signers) { %i[alex jeff] }
    let(:data) { params.merge(scope: :write_apikeys) }

    let(:do_request) do
      post_json '/api/v2/management/api_keys/update',
                multisig_jwt_management_api_v2({ data: data }, *signers)
    end

    let(:params) do
      api_keys_params
    end

    let!(:api_key) { create(:api_key, :with_service_account) }

    context 'valid request' do
      context 'user' do
        let!(:api_key) { create(:api_key, :with_user) }

        before do
          allow(Barong::App.config).to receive_messages(mgn_api_keys_user: true)
        end

        let(:params) do
          {
            uid: api_key.key_holder_account.uid,
            kid: api_key.kid,
            state: 'inactive',
            scopes: 'sell'
          }
        end

        it 'updates api key' do
          do_request
          expect(response.status).to eq(201)

          result = JSON.parse(response.body)
          expect(result.keys).to match_array %w[kid algorithm scope state created_at updated_at]
          expect(result['state']).to eq 'inactive'
          expect(result['scope']).to eq ['sell']
        end
      end

      context 'service account' do
        before do
          allow(Barong::App.config).to receive_messages(mgn_api_keys_sa: true)
        end

        let(:params) do
          {
            uid: api_key.key_holder_account.uid,
            kid: api_key.kid,
            state: 'inactive',
            scopes: 'sell'
          }
        end

        it 'updates api key' do
          do_request
          expect(response.status).to eq(201)

          result = JSON.parse(response.body)
          expect(result.keys).to match_array %w[kid algorithm scope state created_at updated_at]
          expect(result['state']).to eq 'inactive'
          expect(result['scope']).to eq ['sell']
        end
      end
    end

    context 'invalid request' do
      context 'api keys doesnt exist' do
        before do
          allow(Barong::App.config).to receive_messages(mgn_api_keys_sa: true)
        end

        let(:api_keys_params) do
          {
            uid: api_key.key_holder_account.uid,
            kid: 'random kid'
          }
        end

        it 'should raise an error' do
          do_request
          expect(response.status).to eq(422)
          expect_body.to eq(error: 'api_key_doesnt_exist')
        end
      end

      context 'service account doesnt exist' do
        before do
          allow(Barong::App.config).to receive_messages(mgn_api_keys_sa: true)
        end

        let(:api_keys_params) do
          {
            uid: ServiceAccount::UID_PREFIX + 'random',
            kid: api_key.kid
          }
        end

        it 'should raise an error' do
          do_request
          expect(response.status).to eq(422)
          expect_body.to eq(error: 'service_account_doesnt_exist')
        end
      end

      context 'user doesnt exist' do
        before do
          allow(Barong::App.config).to receive_messages(mgn_api_keys_user: true)
        end

        let(:api_keys_params) do
          {
            uid: UIDGenerator.generate(Barong::App.config.uid_prefix),
            kid: api_key.kid
          }
        end

        it 'should raise an error' do
          do_request
          expect(response.status).to eq(422)
          expect_body.to eq(error: 'user_doesnt_exist')
        end
      end

      context 'disabled endpoint' do
        let(:api_keys_params) do
          {
            uid: UIDGenerator.generate(Barong::App.config.uid_prefix),
            kid: api_key.kid
          }
        end

        it 'should raise an error' do
          do_request
          expect(response.status).to eq(422)
          expect_body.to eq(error: 'disabled_management_endpoint')
        end
      end

      context 'unexisting uid' do

        let(:api_keys_params) do
          {
            uid: 'random',
            kid: api_key.kid
          }
        end

        it 'should raise an error' do
          do_request
          expect(response.status).to eq(422)
          expect_body.to eq(error: 'uid_prefix_doesnt_exist')
        end
      end
    end
  end
end
