# frozen_string_literal: true

require 'spec_helper'

describe Admin::ProfilesController, type: :controller do
  let!(:current_account) { create(:account, role: 'admin') }
  before { login_as current_account }

  describe 'GET #index' do
    let!(:profile1) { create(:profile) }
    let!(:profile2) { create(:profile) }

    it 'returns a pending profiles by default' do
      get :index
      expect(response).to be_success
      expect(assigns(:profiles)).to eq [profile1, profile2]
    end
  end

  describe 'GET #show' do
    let!(:profile) { create(:profile) }
    let!(:document) { create(:document, account: profile.account) }

    it 'returns a success response' do
      get :show, params: { id: profile.id }
      expect(response).to be_success
      expect(assigns(:profile)).to eq profile
      expect(assigns(:documents)).to eq [document]
    end
  end

  context 'PUT #document_label' do
    let!(:profile) { create(:profile) }
    let!(:label) do
      create(
        :label,
        account: profile.account,
        key: 'document',
        value: 'created',
        scope: 'private'
      )
    end
    let(:do_request) { put :document_label, params: { id: profile.id, state: value } }

    context 'when value is valid' do
      context 'when value is approved' do
        let(:value) { 'verified' }

        before do
          set_level(profile.account, 3)
        end

        it 'updates a value' do
          expect { do_request }.to change { label.reload.value }.to(value)
          expect(response).to redirect_to admin_profile_path
        end

        it 'changes level to 4' do
          expect { do_request }.to change { profile.account.reload.level }.to(4)
          expect(response).to redirect_to admin_profile_path
        end
      end

      context 'when state is rejected' do
        let(:value) { 'rejected' }
        let!(:label) do
          create(
            :label,
            account: profile.account,
            key: 'document',
            value: 'verified',
            scope: 'private'
          )
        end

        before do
          set_level(profile.account, 4)
        end

        it 'updates a label' do
          expect { do_request }.to change { label.reload.value }.to(value)
          expect(response).to redirect_to admin_profile_path
        end

        it 'change level to 3' do
          expect { do_request }.to change { profile.account.reload.level }.to(3)
          expect(response).to redirect_to admin_profile_path
        end
      end
    end

    context 'when user has level 1' do
      let(:value) { 'verified' }

      before do
        set_level(profile.account, 1)
      end

      it 'updates a label' do
        expect { do_request }.to change { label.reload.value }.to(value)
        expect(response).to redirect_to admin_profile_path
      end

      it 'does not change the level' do
        expect { do_request }.to_not change { profile.account.reload.level }
        expect(response).to redirect_to admin_profile_path
      end
    end
  end
end
