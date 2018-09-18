# frozen_string_literal: true

RSpec.describe SessionsController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:account] }

  let!(:account) { create(:account, otp_enabled: otp_enabled) }
  let(:otp_enabled) { true }

  describe 'POST #confirm' do
    let(:do_request) { post :confirm, params: { account: params } }
    let(:params) { { email: account.email } }

    context 'when otp is not enabled' do
      let(:otp_enabled) { false }

      it 'renders confirm template' do
        do_request
        expect(response).to be_successful
        expect(assigns(:otp_enabled)).to eq false
        expect(response).to render_template(:confirm)
      end
    end

    context 'when otp is enabled' do
      it 'renders confirm template' do
        do_request
        expect(response).to be_successful
        expect(assigns(:otp_enabled)).to eq true
        expect(response).to render_template(:confirm)
      end
    end

    context 'when params has no email' do
      let(:params) { { email: '' } }

      it 'redirects to new action' do
        do_request
        expect(response).to redirect_to(action: :new)
      end
    end

    describe 'POST #create' do
      let(:do_request) { post :create, params: { account: params } }
      let(:params) do
        {
          email: account.email,
          password: account.password
        }
      end

      context 'when otp is not enabled' do
        let(:otp_enabled) { false }

        it 'sign in an account' do
          do_request
          expect(response).to redirect_to index_path
        end
      end

      context 'when otp is enabled' do
        context 'when code is invalid' do
          before { expect(Vault::TOTP).to receive(:validate?) { false } }

          it 'redirects to confirm action' do
            do_request
            expect(response).to redirect_to accounts_sign_in_confirm_path
          end
        end

        context 'when code is valid' do
          before { expect(Vault::TOTP).to receive(:validate?) { true } }

          it 'sign in an account' do
            do_request
            expect(response).to redirect_to index_path
          end
        end
      end
    end
  end
end
