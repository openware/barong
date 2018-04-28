# frozen_string_literal: true

require 'spec_helper'

describe Admin::ProfilesController, type: :controller do
  let!(:current_account) { create(:account, role: 'admin') }
  before { login_as current_account }

  describe 'GET #index' do
    let!(:approved_profile) { create(:profile, state: 'approved') }
    let!(:pending_profile) { create(:profile, state: 'pending') }

    it 'returns a pending profiles by default' do
      get :index
      expect(response).to be_success
      expect(assigns(:profiles)).to eq [pending_profile]
    end

    it 'returns a approved profiles when filter is approved' do
      get :index, params: { filter: 'approved' }
      expect(response).to be_success
      expect(assigns(:profiles)).to eq [approved_profile]
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

  context 'PUT #change_state' do
    let!(:profile) { create(:profile, state: 'pending') }
    let(:do_request) { put :change_state, params: { id: profile.id, state: state } }

    context 'when state is valid' do
      context 'when state is approved' do
        let(:state) { 'approved' }
        before do
          set_level(profile.account, 3)
        end

        it 'updates a state' do
          expect { do_request }.to change { profile.reload.state }.to('approved')
          expect(response).to redirect_to admin_profile_path
        end

        it 'verifies identity' do
          expect { do_request }.to change { profile.account.reload.level }.to(4)
        end
      end

      context 'when state is rejected' do
        let(:state) { 'rejected' }
        before do
          set_level(profile.account, 4)
        end

        it 'updates a state' do
          expect { do_request }.to change { profile.reload.state }.to('rejected')
          expect(response).to redirect_to admin_profile_path
        end

        it 'change level to 3' do
          expect { do_request }.to change { profile.account.reload.level }.to(3)
        end
      end
    end

    context 'when state is invalid' do
      let(:state) { 'invalid' }

      it 'redirects to index page' do
        expect { do_request }.to_not change { profile.reload.state }
        expect(response).to redirect_to admin_profiles_path
      end
    end
  end
end
