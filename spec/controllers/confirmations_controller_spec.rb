# frozen_string_literal: true

RSpec.describe ConfirmationsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:account]
  end

  describe 'GET #show' do
    let!(:account) do
      create(:account, confirmation_token: Faker::Lorem.word,
                       confirmed_at: nil)
    end
    let(:do_request) do
      get :show, params: { confirmation_token: account.confirmation_token,
                           redirect_uri: redirect_uri }
    end

    let(:old_domain_name) { ENV['DOMAIN_NAME'] }
    before { ENV['DOMAIN_NAME'] = new_domain_name }
    after { ENV['DOMAIN_NAME'] = old_domain_name }

    context 'when params has redirect_uri' do
      let(:redirect_uri) { 'https://frontend.root_domain.io' }

      context 'when redirect_uri match app domain' do
        let(:new_domain_name) { 'root_domain.io' }

        it 'redirects to redirect_uri' do
          do_request
          expect(response).to redirect_to(redirect_uri)
        end
      end

      context 'when domain name is not set' do
        let(:new_domain_name) { nil }

        it 'redirects to new session path' do
          do_request
          expect(response).to redirect_to(new_account_session_path)
        end
      end

      context 'when redirect_uri doent match app domain' do
        let(:new_domain_name) { 'unknown.com' }

        it 'redirects to new session path' do
          do_request
          expect(response).to redirect_to(new_account_session_path)
        end
      end
    end

    context 'when params has no redirect_uri' do
      let(:redirect_uri) { '' }
      let(:new_domain_name) { 'barong.io' }

      it 'redirects to new session path' do
        do_request
        expect(response).to redirect_to(new_account_session_path)
      end
    end
  end
end
