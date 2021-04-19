# frozen_string_literal: true

describe API::V2::Identity::Sessions do
  include_context 'organization memberships'
  include_context 'geoip mock'

  include ActiveSupport::Testing::TimeHelpers
  let!(:create_member_permission) do
    create :permission,
           role: 'member',
           verb: 'all'
  end
  before do
    Rails.cache.delete('permissions')
    allow(Barong::App.config).to receive_messages(captcha: 'recaptcha')
  end

  describe 'POST /api/v2/identity/sessions/switch' do
    let(:otp_enabled) { false }
    let(:session_expire_time) do
      Barong::App.config.session_expire_time
    end
    let(:sign_session) do
      post '/api/v2/identity/sessions', params: {
        email: 'admin@barong.io',
        password: 'testPassword111'
      }
    end

    let(:params) { {} }
    let(:switch_session) { post '/api/v2/identity/sessions/switch', params: params }

    before do
      allow(Barong::App.config).to receive_messages(captcha: 'none')
      allow(Barong::App.config).to receive_messages(captcha: 'recaptcha')
      allow(BarongConfig).to receive(:list).and_return({ 'captcha_protected_endpoints' => ['user_create'] })

      sign_session
    end

    it 'can perform switch session endpoint' do
      switch_session

      expect_status_to_eq 200
    end

    context 'User does not belong to any organization' do
      it 'cannot switch to organization admin of Company A' do
        params[:oid] = 'OID001'
        switch_session

        expect_status_to_eq 404
      end

      it 'cannot switch to organization account of Company A1' do
        params[:oid] = 'OID001AID001'
        switch_session

        expect_status_to_eq 404
      end

      it 'cannot switch to organization account of Company A2' do
        params[:oid] = 'OID001AID002'
        switch_session

        expect_status_to_eq 404
      end

      it 'cannot switch to organization admin of Company B' do
        params[:oid] = 'OID002'
        switch_session

        expect_status_to_eq 404
      end

      it 'cannot switch to organization account of Company B1' do
        params[:oid] = 'OID002AID001'
        switch_session

        expect_status_to_eq 404
      end

      it 'cannot switch to organization account of Company B2' do
        params[:oid] = 'OID002AID002'
        switch_session

        expect_status_to_eq 404
      end
    end

    context 'User belong to the organization' do
      context 'User is barong admin organization' do
        let!(:create_memberships) do
          # Assign user as organization admin
          create(:membership, id: 1, user_id: 1, organization_id: 0)
        end

        it 'can switch to organization admin of Company A' do
          params[:oid] = 'OID001'
          switch_session

          expect_status_to_eq 200
          expect(session.instance_variable_get(:@delegate)[:aid]).to eq(params[:oid])
        end

        it 'can switch to organization account of Company A1' do
          params[:oid] = 'OID001AID001'
          switch_session

          expect_status_to_eq 200
          expect(session.instance_variable_get(:@delegate)[:aid]).to eq(params[:oid])
        end

        it 'can switch to organization account of Company A2' do
          params[:oid] = 'OID001AID002'
          switch_session

          expect_status_to_eq 200
          expect(session.instance_variable_get(:@delegate)[:aid]).to eq(params[:oid])
        end

        it 'can switch to organization admin of Company B' do
          params[:oid] = 'OID002'
          switch_session

          expect_status_to_eq 200
          expect(session.instance_variable_get(:@delegate)[:aid]).to eq(params[:oid])
        end

        it 'can switch to organization account of Company B1' do
          params[:oid] = 'OID002AID001'
          switch_session

          expect_status_to_eq 200
          expect(session.instance_variable_get(:@delegate)[:aid]).to eq(params[:oid])
        end

        it 'can switch to organization account of Company B2' do
          params[:oid] = 'OID002AID002'
          switch_session

          expect_status_to_eq 200
          expect(session.instance_variable_get(:@delegate)[:aid]).to eq(params[:oid])
        end

        it 'can switch session back as the individual user' do
          params[:oid] = 'OID002AID002'
          switch_session
          expect(session.instance_variable_get(:@delegate)[:aid]).to eq(params[:oid])

          post '/api/v2/identity/sessions/switch'
          expect_status_to_eq 200
          expect(session.instance_variable_get(:@delegate)[:aid]).to eq(nil)
        end
      end

      context 'User is organization admin' do
        let!(:create_memberships) do
          # Assign user as organization admin of Company A
          create(:membership, id: 1, user_id: 1, organization_id: 1)
        end

        it 'can switch to organization admin of Company A' do
          params[:oid] = 'OID001'
          switch_session

          expect_status_to_eq 200
          expect(session.instance_variable_get(:@delegate)[:aid]).to eq(params[:oid])
        end

        it 'can switch to organization account of Company A1' do
          params[:oid] = 'OID001AID001'
          switch_session

          expect_status_to_eq 200
          expect(session.instance_variable_get(:@delegate)[:aid]).to eq(params[:oid])
        end

        it 'can switch to organization account of Company A2' do
          params[:oid] = 'OID001AID002'
          switch_session

          expect_status_to_eq 200
          expect(session.instance_variable_get(:@delegate)[:aid]).to eq(params[:oid])
        end

        it 'cannot switch to organization admin of Company B' do
          params[:oid] = 'OID002'
          switch_session

          expect_status_to_eq 404
        end

        it 'cannot switch to organization account of Company B1' do
          params[:oid] = 'OID002AID001'
          switch_session

          expect_status_to_eq 404
        end

        it 'cannot switch to organization account of Company B2' do
          params[:oid] = 'OID002AID002'
          switch_session

          expect_status_to_eq 404
        end
      end

      context 'User is organization account' do
        let!(:create_memberships) do
          # Assign user as organization account of Group A1
          create(:membership, id: 1, user_id: 1, organization_id: 3)
        end

        it 'cannot switch to organization admin of Company A' do
          params[:oid] = 'OID001'
          switch_session

          expect_status_to_eq 404
        end

        it 'can switch to organization account of Company A1' do
          params[:oid] = 'OID001AID001'
          switch_session

          expect_status_to_eq 200
          expect(session.instance_variable_get(:@delegate)[:aid]).to eq(params[:oid])
        end

        it 'cannot switch to organization account of Company A2' do
          params[:oid] = 'OID001AID002'
          switch_session

          expect_status_to_eq 404
        end

        it 'cannot switch to organization admin of Company B' do
          params[:oid] = 'OID002'
          switch_session

          expect_status_to_eq 404
        end

        it 'cannot switch to organization account of Company B1' do
          params[:oid] = 'OID002AID001'
          switch_session

          expect_status_to_eq 404
        end

        it 'cannot switch to organization account of Company B2' do
          params[:oid] = 'OID002AID002'
          switch_session

          expect_status_to_eq 404
        end
      end
    end
  end
end
