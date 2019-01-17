# frozen_string_literal: true

describe API::V2::Resource::Sessions do
  include ActiveSupport::Testing::TimeHelpers
  include_context 'bearer authentication'

  describe 'DELETE /api/v2/identity/sessions' do
    let!(:email) { 'user@gmail.com' }
    let!(:password) { 'testPassword111' }
    let(:identity_uri) { '/api/v2/identity/sessions' }
    let(:resource_uri) { '/api/v2/resource/sessions' }
    let(:params) do
      {
        email: email,
        password: password
      }
    end
    subject!(:user) do
      create :user,
             email: email,
             password: password,
             password_confirmation: password
    end

    context 'With valid session' do
      let(:do_create_session_request) { post identity_uri, params: params }
      let(:do_delete_session_request) { delete resource_uri, headers: auth_header }

      it 'Deletes session' do
        do_create_session_request
        expect(session[:uid]).to eq(user.uid)
        do_delete_session_request
        expect(session[:uid]).to eq(nil)
      end
    end

    context 'With invalid session' do
      let(:do_delete_session_request) { delete resource_uri }

      it 'Returns error' do
        do_delete_session_request
        expect(request.session[:uid]).to eq(nil)
        expect(response.code).to eq('401')
        expect(response.body).to eq("{\"error\":{\"code\":2001,\"message\":\"2001: Authorization failed: Header Authorization missing\"}}")
      end
    end
  end
end