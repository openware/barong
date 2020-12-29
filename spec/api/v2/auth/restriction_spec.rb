# frozen_string_literal: true

require 'spec_helper'

describe '/api/v2/auth functionality test' do
  include_context 'geoip mock'

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
  let(:do_create_session_request) { post uri, params: params }
  let(:auth_request) { '/api/v2/auth/tasty_endpoint' }
  let(:auth_session_create_request) { '/api/v2/auth/api/v2/barong/identity/sessions' }


  describe 'test blocklogin restriction' do
    before do
      allow(Rails.cache).to receive(:delete_matched).and_return(nil)
      Rails.cache.delete('restrictions')
    end

    context 'block session creation' do
      let!(:restriction) { create(:restriction, value: 'EUROPE', scope: 'continent', category: 'blocklogin', code: 425) }
      before do
        allow_any_instance_of(Barong::Authorize).to receive(:validate_session!).and_return(true)
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(london_ip)
      end

      it do
        post auth_session_create_request, params: params
        expect(response.status).to eq(restriction.code)
      end

      it do
        do_create_session_request # This request will be successful because path doesn't include 'api/v2/auth'
        get auth_request
        expect(response.status).to eq(200)
      end
    end
  end
  describe 'test blacklist restrictions' do
    before do
      allow_any_instance_of(Barong::Authorize).to receive(:validate_session!).and_return(true)
      Rails.cache.delete('restrictions')
      do_create_session_request
    end

    context 'restrict by ip' do
      let!(:restriction) { create(:restriction, value: '192.168.0.1', scope: 'ip', category: 'blacklist') }
      let!(:disabled) { create(:restriction, value: '192.168.0.3', scope: 'ip', state: 'disabled', category: 'blacklist') }

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
      let!(:restriction) { create(:restriction, value: '192.168.32.0/24', scope: 'ip_subnet', category: 'blacklist') }

      it 'request with restricted ip' do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('192.168.32.42')
        get auth_request

        expect(response.status).to eq(403)
        expect(response.headers['Authorization']).to be_nil
        expect(response.body).to eq("{\"errors\":[\"authz.restrict.blacklist\"]}")
      end

      it 'request with non-restricted ip' do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('192.168.33.3')
        get auth_request

        expect(response.status).to eq(200)
      end
    end

    context 'geoip' do
      context 'restricts with country' do
        let!(:restriction) { create(:restriction, value: 'japan', scope: 'country', category: 'blacklist') }

        it 'with restricted ip' do
          allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(tokyo_ip)
          get auth_request
          expect(response.status).to eq(423)
          expect(response.headers['Authorization']).to be_nil
          expect(response.body).to eq("{\"errors\":[\"authz.restrict.blacklist\"]}")
        end

        it 'with non-restricted ip' do
          allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(london_ip)
          get auth_request
          expect(response.status).to eq(200)
        end
      end

      context 'restricts with continent' do
        let!(:restriction) { create(:restriction, value: 'EUROPE', scope: 'continent', category: 'blacklist') }

        it 'with restricted ip' do
          allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(london_ip)
          get auth_request
          expect(response.status).to eq(423)
          expect(response.headers['Authorization']).to be_nil
          expect(response.body).to eq("{\"errors\":[\"authz.restrict.blacklist\"]}")
        end

        it 'with non-restricted ip' do
          allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(tokyo_ip)
          get auth_request
          expect(response.status).to eq(200)
        end
      end
    end
  end

  describe 'test restriction ierarchy' do
    before do
      allow_any_instance_of(Barong::Authorize).to receive(:validate_session!).and_return(true)
      Rails.cache.delete('restrictions')
      do_create_session_request
      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('192.168.0.1')
    end

    context 'whitelist -> maintenance' do
      let!(:maintenance_restriction) { create(:restriction, value: '192.168.0.1', scope: 'ip', category: 'maintenance') }
      let!(:whitelist_restriction) { create(:restriction, value: '192.168.0.1', scope: 'ip', category: 'whitelist') }

      it '200' do
        get auth_request

        expect(response.status).to eq(200)
      end
    end


    context 'maintenance -> blacklist' do
      let!(:blacklist_restriction) { create(:restriction, value: '192.168.0.1', scope: 'ip', category: 'blacklist') }
      let!(:maintenance_restriction) { create(:restriction, value: '192.168.0.1', scope: 'ip', category: 'maintenance') }

      context 'standard code error' do
        it '471' do
          get auth_request

          expect(response.status).to eq(471)
        end
      end
    end

    context 'blacklist' do
      context 'standard code error' do
        let!(:blacklist_restriction) { create(:restriction, value: '192.168.0.1', scope: 'ip', category: 'blacklist') }

        it '401' do
          get auth_request

          expect(response.status).to eq(401)
        end
      end

      context 'custom code error' do
        let!(:blacklist_restriction) { create(:restriction, value: '192.168.0.1', scope: 'ip', category: 'blacklist', code: 403) }

        it '403' do
          get auth_request

          expect(response.status).to eq(403)
        end
      end
    end
  end
end
