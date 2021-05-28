# frozen_string_literal: true

describe API::V2::Identity::Sessions do
  include_context 'organization memberships'
  include_context 'geoip mock'

  include ActiveSupport::Testing::TimeHelpers
  let!(:create_member_permission) do
    create(:permission, role: 'admin', verb: 'all')
    create(:permission, role: 'member', verb: 'all')
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
    let(:sign_params) { {} }
    let(:sign_session) do
      post '/api/v2/identity/sessions', params: sign_params
    end

    let(:params) { {} }
    let(:switch_session) { post '/api/v2/identity/sessions/switch', params: params }

    let!(:create_memberships) do
      # Assign users with organizations
      create(:membership, id: 2, user_id: 2, organization_id: 1)
      create(:membership, id: 3, user_id: 3, organization_id: 3)
      create(:membership, id: 4, user_id: 4, organization_id: 3)
      create(:membership, id: 5, user_id: 5, organization_id: 5)
      create(:membership, id: 6, user_id: 6, organization_id: 3)
      create(:membership, id: 7, user_id: 6, organization_id: 4)
    end

    before do
      allow(Barong::App.config).to receive_messages(captcha: 'none')
      allow(Barong::App.config).to receive_messages(captcha: 'recaptcha')
      allow(BarongConfig).to receive(:list).and_return({ 'captcha_protected_endpoints' => ['user_create'] })

      sign_session
    end

    context 'User does not belong to any organization' do
      let(:sign_params) do
        {
          email: 'user1@barong.io',
          password: 'testPassword111'
        }
      end

      it 'can perform switch session endpoint' do
        switch_session

        expect_status_to_eq 200
      end

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

    context 'User is admin with AdminSwitchSession ability' do
      let(:sign_params) do
        {
          email: 'admin@barong.io',
          password: 'testPassword111'
        }
      end

      it 'can switch to organization admin of Company A' do
        params[:oid] = 'OID001'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')
      end

      it 'can switch to organization account Group A1' do
        params[:oid] = 'OID001AID001'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001AID001')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')
      end

      it 'can switch to organization account Group A2' do
        params[:oid] = 'OID001AID002'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001AID002')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')
      end

      it 'can switch to organization admin of Company B' do
        params[:oid] = 'OID002'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID002')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID002')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')
      end

      it 'can switch to organization account Group B1' do
        params[:oid] = 'OID002AID001'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID002AID001')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID002')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')
      end

      it 'can switch to organization account Group B2' do
        params[:oid] = 'OID002AID002'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID002AID002')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID002')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')
      end

      it 'can get role of reuested user when admin switch to a user' do
        params[:oid] = 'OID001AID001'
        params[:uid] = 'IDFE10A90003'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001AID001')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')
        expect(session.instance_variable_get(:@delegate)[:role]).to eq('accountant')
      end

      it 'can get default role when admin switch to a organization' do
        params[:oid] = 'OID001AID001'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001AID001')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')
        expect(session.instance_variable_get(:@delegate)[:role]).to eq('member')
      end

      it 'can switch session back as the individual user' do
        params[:oid] = 'OID002AID002'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID002AID002')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID002')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')

        post '/api/v2/identity/sessions/switch'
        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('IDFE09081060')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq(nil)
        expect(session.instance_variable_get(:@delegate)[:rif]).to eq(nil)
      end
    end

    context 'User is organization admin' do
      let(:sign_params) do
        {
          email: 'adminA@barong.io',
          password: 'testPassword111'
        }
      end

      it 'can switch to organization admin of Company A' do
        params[:oid] = 'OID001'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE10A90000')
      end

      it 'can switch to organization account of Company A1' do
        params[:oid] = 'OID001AID001'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001AID001')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE10A90000')
      end

      it 'can switch to organization account of Company A2' do
        params[:oid] = 'OID001AID002'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001AID002')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE10A90000')
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
      let(:sign_params) do
        {
          email: 'memberA1@barong.io',
          password: 'testPassword111'
        }
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
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001AID001')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE10A90001')
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
