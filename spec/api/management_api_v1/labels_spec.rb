# frozen_string_literal: true

describe ManagementAPI::V1::Labels, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        write_labels:  { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
        read_labels:  { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
      }
  end

  let!(:account) { create(:account) }

  describe '#list' do
    let!(:private_label) do
      create(:label, scope: 'private', account: account)
    end
    let!(:public_label) do
      create(:label, scope: 'public', account: account)
    end
    let(:data) do
      {
        account_uid: account.uid
      }
    end
    let(:signers) { %i[alex] }

    let(:do_request) do
      post_json '/management_api/v1/labels/list',
                multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    it 'get list of account labels' do
      do_request
      expect(response.status).to eq 201
      expect(json_body.size).to eq 2
    end
  end

  describe 'create label' do
    let(:data) do
      {
        account_uid: account.uid,
        key: 'email',
        value: 'verified',
        scope: 'private'
      }
    end
    let(:expected_attributes) do
      {
        'key' => 'email',
        'value' => 'verified',
        'account_id' => account.id,
        'scope' => 'private'
      }
    end
    let(:signers) { %i[alex jeff] }

    let(:do_request) do
      post_json '/management_api/v1/labels',
                multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    it 'creates a label' do
      expect { do_request }.to change { Label.count }.from(0).to(1)
      expect(response.status).to eq 201
      expect(Label.last.attributes).to include(expected_attributes)
    end

    it 'denies access unless enough signatures are supplied' do
      signers.clear.concat %i[james jeff]
      expect { do_request }.to_not change { Label.count }
      expect(response.status).to eq 401
    end

    it 'denies when account is not found' do
      data[:account_uid] = 'invalid'
      expect { do_request }.to_not change { Label.count }
      expect(response.status).to eq 404
    end

    context 'when data is blank' do
      let(:data) { {} }

      it 'renders errors' do
        do_request
        expect(response.status).to eq 422
        expect_body.to eq(error: 'Account UID is missing, Account UID is empty, Key is missing, Key is empty, Value is missing, Value is empty')
      end
    end
  end

  describe 'update label' do
    let!(:label) do
      create(:label, key: 'email', value: 'verified', scope: 'private', account: account)
    end

    let(:data) do
      {
        account_uid: account.uid,
        key: 'email',
        value: 'rejected'
      }
    end
    let(:signers) { %i[alex jeff] }

    let(:do_request) do
      put_json '/management_api/v1/labels',
               multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    it 'updates a label' do
      expect { do_request }.to change { label.reload.value }.from('verified').to('rejected')
      expect(response.status).to eq 200
    end

    it 'denies access unless enough signatures are supplied' do
      signers.clear.concat %i[james jeff]
      expect { do_request }.to_not change { label.reload.value }
      expect(response.status).to eq 401
    end

    it 'denies when account is not found' do
      data[:account_uid] = 'invalid'
      expect { do_request }.to_not change { label.reload.value }
      expect(response.status).to eq 404
    end

    context 'when data is blank' do
      let(:data) { {} }

      it 'renders errors' do
        do_request
        expect(response.status).to eq 422
        expect_body.to eq(error: 'Account UID is missing, Account UID is empty, Key is missing, Key is empty, Value is missing, Value is empty')
      end
    end
  end

  describe 'delete label' do
    let!(:label) do
      create(:label, key: 'email', value: 'verified', scope: 'private', account: account)
    end

    let(:data) do
      {
        account_uid: account.uid,
        key: 'email'
      }
    end
    let(:signers) { %i[alex jeff] }

    let(:do_request) do
      post_json '/management_api/v1/labels/delete',
                multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    it 'deletes a label' do
      expect { do_request }.to change { Label.count }.from(1).to(0)
      expect(response.status).to eq 204
    end

    it 'denies access unless enough signatures are supplied' do
      signers.clear.concat %i[james jeff]
      expect { do_request }.to_not change { label.reload.value }
      expect(response.status).to eq 401
    end

    it 'denies when account is not found' do
      data[:account_uid] = 'invalid'
      expect { do_request }.to_not change { label.reload.value }
      expect(response.status).to eq 404
    end
  end
end
