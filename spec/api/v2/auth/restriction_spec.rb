# frozen_string_literal: true

require 'spec_helper'

describe '/api/v2/auth functionality test' do
  let(:uri) { '/api/v2/identity/sessions' }
  let!(:create_permissions) do
    create :permission, role: 'member', action: 'ACCEPT', verb: 'all', path: 'tasty_endpoint'
    Rails.cache.delete('permissions')
  end
  let!(:user) { create(:user) }
  let(:params) do
    {
      email: user.email,
      password: user.password
    }
  end
  let(:do_create_session_request) { post uri, params: params, headers: { 'HTTP_USER_AGENT' => 'random-browser' } }
  let(:auth_request) { '/api/v2/auth/tasty_endpoint' }

  describe 'test restrictions' do
    before do
      Rails.cache.delete('restrictions')
      do_create_session_request
    end

    context 'restrict by ip' do
      let!(:restriction) { create(:restriction, value: '192.168.0.1', scope: 'ip') }
      let!(:disabled) { create(:restriction, value: '192.168.0.3', scope: 'ip', state: 'disabled') }

      it 'request with restricted ip' do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('192.168.0.1')
        get auth_request

        expect(response.status).to eq(401)
        expect(response.headers['Authorization']).to be_nil
      end

      it 'request with non-restricted ip' do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('192.168.0.2')
        get auth_request
        expect(response.status).to eq(200)
      end

      it 'request with disabled restriction' do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('192.168.0.3')
        get auth_request
        expect(response.status).to eq(200)
      end
    end

    context 'restricts with ip subnet' do
      let!(:restriction) { create(:restriction, value: '192.168.32.0/24', scope: 'ip_subnet') }

      it 'request with restricted ip' do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('192.168.32.42')
        get auth_request

        expect(response.status).to eq(401)
        expect(response.headers['Authorization']).to be_nil
      end

      it 'request with non-restricted ip' do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('192.168.33.3')
        get auth_request

        expect(response.status).to eq(200)
      end
    end
  end
end
