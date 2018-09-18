# frozen_string_literal: true

require 'spec_helper'

describe Admin::AccountsController, type: :controller do
  let!(:current_account) { create(:account, role: 'admin') }
  let!(:discarded_account) { create(:account, discarded_at: 1.hour.ago) }
  before { login_as current_account }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: {}
      expect(response).to be_successful
      expect(assigns(:accounts).count).to eq 1
    end
  end

  describe 'GET #edit' do
    let(:do_request) { get :edit, params: { id: account.id } }

    context 'when account is current_account' do
      let!(:account) { current_account }

      it 'renders cancan error ' do
        do_request
        expect(response).to redirect_to new_account_session_url
      end
    end

    context 'when account is other account' do
      let!(:account) { create(:account) }

      it 'returns a success response' do
        do_request
        expect(response).to be_successful
        expect(assigns(:account)).to eq account
      end
    end
  end

  describe 'PUT #update' do
    let(:do_request) { put :update, params: { id: account.id, account: params } }
    let(:params) { { role: 'compliance' } }

    context 'when account is current_account' do
      let!(:account) { current_account }

      it 'renders cancan error ' do
        do_request
        expect(response).to redirect_to new_account_session_url
      end
    end

    context 'when account is other account' do
      let!(:account) { create(:account, role: 'member') }

      it 'updates an account role' do
        expect { do_request }.to change { account.reload.role }
          .from('member').to('compliance')
        expect(response).to redirect_to admin_accounts_url
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:do_request) { delete :destroy, params: { id: account.id } }

    context 'when account is current_account' do
      let!(:account) { current_account }

      it 'renders cancan error ' do
        do_request
        expect(response).to redirect_to new_account_session_url
      end
    end

    context 'when account is other account' do
      let!(:account) { create(:account) }

      it 'does not destroy an account' do
        expect { do_request }.to_not change(Account, :count)
        expect(response).to redirect_to(admin_accounts_url)
      end

      it 'makes an account as discarded' do
        expect { do_request }.to change { account.reload.discarded_at }.to be
        expect(response).to redirect_to(admin_accounts_url)
      end
    end
  end
end
