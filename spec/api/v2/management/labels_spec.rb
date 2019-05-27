# frozen_string_literal: true

require 'rails_helper'
require 'pry'

describe API::V2::Management::Labels, type: :request do
    before do
      defaults_for_management_api_v2_security_configuration!
      management_api_v2_security_configuration.merge! \
        scopes: {
          write_labels:  { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
          read_labels:  { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
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
    let!(:user) { create(:user) }

    describe '#list' do
      let!(:private_label) do
        create(:label, scope: 'private', user: user)
      end
      let!(:public_label) do
        create(:label, scope: 'public', user: user)
      end
      let(:data) do
        {
          user_uid: user.uid
        }
      end
      let(:signers) { %i[alex] }

      let(:do_request) do
        post_json '/api/v2/management/labels/list',
                  multisig_jwt_management_api_v2({ data: data }, *signers)
      end

      it 'get list of user labels' do
        do_request
        expect(response.status).to eq 201
        expect(json_body.size).to eq 2
      end
    end

    describe 'create label' do
      let(:data) do
        {
          user_uid: user.uid,
          key: 'email',
          value: 'verified',
          scope: 'private'
        }
      end
      let(:expected_attributes) do
        {
          'key' => 'email',
          'value' => 'verified',
          'user_id' => user.id,
          'scope' => 'private'
        }
      end
      let(:signers) { %i[alex jeff] }

      let(:do_request) do
        post_json '/api/v2/management/labels',
                  multisig_jwt_management_api_v2({ data: data }, *signers)
      end

      it 'creates a label' do
        expect { do_request }.to change { Label.count }.from(0).to(1)
        expect(response.status).to eq 201
        expect(Label.first.attributes).to include(expected_attributes)
      end

      it 'denies access unless enough signatures are supplied' do
        signers.clear.concat %i[james jeff]
        expect { do_request }.to_not change { Label.count }
        expect(response.status).to eq 401
      end

      it 'denies when user is not found' do
        data[:user_uid] = 'invalid'
        expect { do_request }.to_not change { Label.count }
        expect(response.status).to eq 404
      end

      context 'when data is blank' do
        let(:data) { {} }

        it 'renders errors' do
          do_request
          expect(response.status).to eq 422
          expect_body.to eq(error: 'user_uid is missing, user_uid is empty, key is missing, key is empty, value is missing, value is empty')
        end
      end
    end

    describe 'update label' do
      let!(:label) do
        create(:label, key: 'email', value: 'verified', scope: 'private', user: user)
      end

      let(:data) do
        {
          user_uid: user.uid,
          key: 'email',
          value: 'rejected'
        }
      end
      let(:signers) { %i[alex jeff] }

      let(:do_request) do
        put_json '/api/v2/management/labels',
                 multisig_jwt_management_api_v2({ data: data }, *signers)
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

      it 'denies when user is not found' do
        data[:user_uid] = 'invalid'
        expect { do_request }.to_not change { label.reload.value }
        expect(response.status).to eq 404
      end

      context 'when data is blank' do
        let(:data) { {} }

        it 'renders errors' do
          do_request
          expect(response.status).to eq 422
          expect_body.to eq(error: 'user_uid is missing, user_uid is empty, key is missing, key is empty, value is missing, value is empty')
        end
      end
    end

    describe 'delete label' do
      let!(:label) do
        create(:label, key: 'email', value: 'verified', scope: 'private', user: user)
      end

      let(:data) do
        {
          user_uid: user.uid,
          key: 'email'
        }
      end
      let(:signers) { %i[alex jeff] }

      let(:do_request) do
        post_json '/api/v2/management/labels/delete',
                  multisig_jwt_management_api_v2({ data: data }, *signers)
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

      it 'denies when user is not found' do
        data[:user_uid] = 'invalid'
        expect { do_request }.to_not change { label.reload.value }
        expect(response.status).to eq 404
      end
    end
  end
