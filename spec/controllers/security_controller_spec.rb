# frozen_string_literal: true

RSpec.describe SecurityController, type: :controller do
  let!(:current_account) { create(:account, otp_enabled: false) }
  before { login_as current_account }

  describe 'GET #enable' do
    let(:do_request) { get :enable }

    context 'when otp is enabled' do
      let!(:current_account) { create(:account, otp_enabled: true) }

      it 'redirect to index_path' do
        do_request
        expect(response).to redirect_to index_path
        expect(flash[:alert]).to eq '2FA has been enabled for this account'
      end
    end

    context 'when vault is not available' do
      before { expect(Vault::TOTP).to receive(:server_available?) { false } }

      it 'redirect to index_path' do
        do_request
        expect(response).to redirect_to index_path
        expect(flash[:alert]).to eq '2FA is disabled'
      end
    end

    context 'when otp is not enabled' do
      before { expect(Vault::TOTP).to receive(:server_available?) { true } }

      it 'creates vault secret' do
        expect(Vault::TOTP).to receive(:create)
          .with(current_account.uid, current_account.email)
        expect(Vault::TOTP).to receive(:otp_secret)
        do_request
      end
    end
  end

  describe 'POST #confirm' do
    let(:do_request) { post :confirm, params: params }
    let(:params) { { otp: '12345' } }

    context 'when otp is enabled' do
      let!(:current_account) { create(:account, otp_enabled: true) }

      it 'redirect to index_path' do
        do_request
        expect(response).to redirect_to index_path
        expect(flash[:alert]).to eq '2FA has been enabled for this account'
      end
    end

    context 'when vault is not available' do
      before { expect(Vault::TOTP).to receive(:server_available?) { false } }

      it 'redirect to index_path' do
        do_request
        expect(response).to redirect_to index_path
        expect(flash[:alert]).to eq '2FA is disabled'
      end
    end

    context 'when otp is not enabled' do
      before { expect(Vault::TOTP).to receive(:server_available?) { true } }

      context 'when code is invalid' do
        before { expect(Vault::TOTP).to receive(:validate?) { false } }

        it 'redirect to security_path' do
          do_request
          expect(response).to redirect_to security_path
          expect(flash[:alert]).to eq 'Code is invalid'
        end
      end

      context 'when code is valid' do
        before { expect(Vault::TOTP).to receive(:validate?) { true } }

        it 'enables otp' do
          expect { do_request }.to change { current_account.reload.otp_enabled }.to(true)
          expect(response).to redirect_to index_path
          expect(flash[:notice]).to eq '2FA is enabled'
        end
      end
    end
  end
end
