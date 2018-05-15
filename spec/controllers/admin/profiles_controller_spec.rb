# frozen_string_literal: true

require 'spec_helper'

describe Admin::ProfilesController, type: :controller do
  let!(:current_account) { create(:account, role: 'admin') }
  let!(:discarded_account) { create(:account, discarded_at: 1.hour.ago) }
  let!(:discarded_profile) { create(:profile, account: discarded_account) }

  before { login_as current_account }

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
          expect(response).to redirect_to admin_account_path(profile.account)
        end

        it 'changes level to 4' do
          expect { do_request }.to change { profile.account.reload.level }.to(4)
          expect(response).to redirect_to admin_account_path(profile.account)
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
          expect(response).to redirect_to admin_account_path(profile.account)
        end

        it 'change level to 3' do
          expect { do_request }.to change { profile.account.reload.level }.to(3)
          expect(response).to redirect_to admin_account_path(profile.account)
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
        expect(response).to redirect_to admin_account_path(profile.account)
      end

      it 'does not change the level' do
        expect { do_request }.to_not change { profile.account.reload.level }
        expect(response).to redirect_to admin_account_path(profile.account)
      end
    end
  end
end
