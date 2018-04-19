# frozen_string_literal: true

RSpec.describe IndexController, type: :controller do
  describe 'GET #index' do
    let(:do_request) { get :index }

    context 'when account is not signed in' do
      it 'redirect to new_account_session_url' do
        do_request
        expect(response).to redirect_to new_account_session_url
      end
    end

    context 'when current level is 1' do
      let!(:current_account) { create(:account, level: 1) }
      before { login_as current_account }

      it 'redirect to new_phone_path' do
        do_request
        expect(response).to redirect_to new_phone_path
      end
    end

    context 'when current level is 2 and account has no documents' do
      let!(:current_account) { create(:account, level: 2) }
      before { login_as current_account }

      it 'redirect to new_profile_path' do
        do_request
        expect(response).to redirect_to new_profile_path
      end
    end
  end
end
