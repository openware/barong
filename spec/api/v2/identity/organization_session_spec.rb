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
      create(:membership, id: 2, user_id: 2, organization_id: 1, role: 'admin')
      create(:membership, id: 3, user_id: 3, organization_id: 3, role: 'member')
      create(:membership, id: 4, user_id: 4, organization_id: 3, role: 'member')
      create(:membership, id: 5, user_id: 5, organization_id: 5, role: 'member')
      create(:membership, id: 6, user_id: 6, organization_id: 3, role: 'accountant')
      create(:membership, id: 7, user_id: 6, organization_id: 4, role: 'member')
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

        expect_status_to_eq 401
      end

      it 'cannot switch to organization account of Company A1' do
        params[:oid] = 'OID001AID001'
        switch_session

        expect_status_to_eq 401
      end

      it 'cannot switch to organization account of Company A2' do
        params[:oid] = 'OID001AID002'
        switch_session

        expect_status_to_eq 401
      end

      it 'cannot switch to organization admin of Company B' do
        params[:oid] = 'OID002'
        switch_session

        expect_status_to_eq 401
      end

      it 'cannot switch to organization account of Company B1' do
        params[:oid] = 'OID002AID001'
        switch_session

        expect_status_to_eq 401
      end

      it 'cannot switch to organization account of Company B2' do
        params[:oid] = 'OID002AID002'
        switch_session

        expect_status_to_eq 401
      end
    end

    context 'User has AdminSwitchSession ability' do
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
        expect(session.instance_variable_get(:@delegate)[:user_role]).to eq('admin')

        result = JSON.parse(response.body)
        expect(result['organization']['name']).to eq 'Company A'
        expect(result['organization']['subunit']).to eq nil
      end

      it 'can switch to organization account Group A1' do
        params[:oid] = 'OID001AID001'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001AID001')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')

        result = JSON.parse(response.body)
        expect(result['organization']['subunit']['name']).to eq 'Group A1'
      end

      it 'can switch to organization account Group A2' do
        params[:oid] = 'OID001AID002'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001AID002')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')

        result = JSON.parse(response.body)
        expect(result['organization']['subunit']['name']).to eq 'Group A2'
      end

      it 'can switch to organization admin of Company B' do
        params[:oid] = 'OID002'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID002')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID002')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')

        result = JSON.parse(response.body)
        expect(result['organization']['name']).to eq 'Company B'
        expect(result['organization']['subunit']).to eq nil
      end

      it 'can switch to organization account Group B1' do
        params[:oid] = 'OID002AID001'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID002AID001')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID002')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')

        result = JSON.parse(response.body)
        expect(result['organization']['subunit']['name']).to eq 'Group B1'
      end

      it 'can switch to organization account Group B2' do
        params[:oid] = 'OID002AID002'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID002AID002')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID002')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')

        result = JSON.parse(response.body)
        expect(result['organization']['subunit']['name']).to eq 'Group B2'
      end

      it 'cannot switch to a user in organization' do
        params[:uid] = 'IDFE10A90003'
        switch_session

        expect_status_to_eq 401
      end

      it 'can get org-admin role when admin switch to a organization' do
        params[:oid] = 'OID001'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')
        expect(session.instance_variable_get(:@delegate)[:role]).to eq('org-admin')
      end

      it 'can get org-member role when admin switch to a subunit' do
        params[:oid] = 'OID001AID001'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001AID001')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')
        expect(session.instance_variable_get(:@delegate)[:role]).to eq('org-member')
      end

      it 'can switch to the individual user' do
        params[:uid] = 'IDFE0908101'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('IDFE0908101')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq(nil)
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')
        expect(session.instance_variable_get(:@delegate)[:role]).to eq('member')

        result = JSON.parse(response.body)
        expect(result['organization']).to eq nil
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

        result = JSON.parse(response.body)
        expect(result['organization']).to eq nil
      end
    end

    context 'User has SubunitSwitchSession ability' do
      context 'User is organization admin' do
        let(:sign_params) do
          {
            email: 'adminA@barong.io',
            password: 'testPassword111'
          }
        end

        it 'switch as default account of Company A' do
          expect_status_to_eq 200

          expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001')
          expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
          expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE10A90000')
          expect(session.instance_variable_get(:@delegate)[:role]).to eq('admin')
          expect(session.instance_variable_get(:@delegate)[:user_role]).to eq('org-admin')

          result = JSON.parse(response.body)
          expect(result['organization']['name']).to eq 'Company A'
          expect(result['organization']['subunit']).to eq nil
        end

        it 'can switch to organization admin of Company A' do
          params[:oid] = 'OID001'
          switch_session

          expect_status_to_eq 200
          expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001')
          expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
          expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE10A90000')
          expect(session.instance_variable_get(:@delegate)[:role]).to eq('admin')
          expect(session.instance_variable_get(:@delegate)[:user_role]).to eq('org-admin')

          result = JSON.parse(response.body)
          expect(result['organization']['name']).to eq 'Company A'
          expect(result['organization']['subunit']).to eq nil
        end

        it 'can switch to organization account of Group A1' do
          params[:oid] = 'OID001AID001'
          switch_session

          expect_status_to_eq 200
          expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001AID001')
          expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
          expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE10A90000')
          expect(session.instance_variable_get(:@delegate)[:role]).to eq('org-member')

          result = JSON.parse(response.body)
          expect(result['organization']['subunit']['name']).to eq 'Group A1'
        end

        it 'can switch to organization account of Group A2' do
          params[:oid] = 'OID001AID002'
          switch_session

          expect_status_to_eq 200
          expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001AID002')
          expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
          expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE10A90000')
          expect(session.instance_variable_get(:@delegate)[:role]).to eq('org-member')

          result = JSON.parse(response.body)
          expect(result['organization']['subunit']['name']).to eq 'Group A2'
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

        it 'switch as default account of Group A1' do
          expect_status_to_eq 200

          expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001AID001')
          expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
          expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE10A90001')
          expect(session.instance_variable_get(:@delegate)[:role]).to eq('member')
          expect(session.instance_variable_get(:@delegate)[:user_role]).to eq('org-member')

          result = JSON.parse(response.body)
          expect(result['organization']['subunit']['name']).to eq 'Group A1'
        end

        it 'can switch to organization account of Group A1' do
          params[:oid] = 'OID001AID001'
          switch_session

          expect_status_to_eq 200
          expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001AID001')
          expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
          expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE10A90001')
          expect(session.instance_variable_get(:@delegate)[:role]).to eq('member')
          expect(session.instance_variable_get(:@delegate)[:user_role]).to eq('org-member')

          result = JSON.parse(response.body)
         expect(result['organization']['subunit']['name']).to eq 'Group A1'
        end

        it 'cannot switch to organization account of Group A2' do
          params[:oid] = 'OID001AID002'
          switch_session

          expect_status_to_eq 404
        end

        it 'cannot switch to organization admin of Company B' do
          params[:oid] = 'OID002'
          switch_session

          expect_status_to_eq 404
        end

        it 'cannot switch to organization account of Group B1' do
          params[:oid] = 'OID002AID001'
          switch_session

          expect_status_to_eq 404
        end

        it 'cannot switch to organization account of Group B2' do
          params[:oid] = 'OID002AID002'
          switch_session

          expect_status_to_eq 404
        end
      end

      context 'User has multiple organization accounts' do
        let(:sign_params) do
          {
            email: 'memberA1A2@barong.io',
            password: 'testPassword111'
          }
        end

        it 'can switch to organization account of Group A1' do
          params[:oid] = 'OID001AID001'
          switch_session

          expect_status_to_eq 200
          expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001AID001')
          expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
          expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE10A90003')
          expect(session.instance_variable_get(:@delegate)[:role]).to eq('accountant')

          result = JSON.parse(response.body)
          expect(result['organization']['subunit']['name']).to eq 'Group A1'
        end

        it 'can switch to organization account of Group A2' do
          params[:oid] = 'OID001AID002'
          switch_session

          expect_status_to_eq 200
          expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID001AID002')
          expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID001')
          expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE10A90003')
          expect(session.instance_variable_get(:@delegate)[:role]).to eq('member')

          result = JSON.parse(response.body)
          expect(result['organization']['subunit']['name']).to eq 'Group A2'
        end
      end

      context 'Organization have banned status' do
        let(:sign_params) do
          {
            email: 'admin@barong.io',
            password: 'testPassword111'
          }
        end

        let!(:banned_organizations) do
          create(:organization, id: 7, oid: 'OID003', parent_organization: nil, name: 'Company C', status: 'banned')
          create(:organization, id: 8, oid: 'OID003AID001', parent_organization: 7, name: 'Group C1')
          create(:organization, id: 9, oid: 'OID003AID002', parent_organization: 7, name: 'Group C2')
        end

        it 'cannot switch to organization Company C' do
          params[:oid] = 'OID003'
          switch_session

          expect_status_to_eq 404
        end

        it 'cannot switch to subunit Group C1' do
          params[:oid] = 'OID003AID001'
          switch_session

          expect_status_to_eq 404
        end

        it 'cannot switch to subunit Group C2' do
          params[:oid] = 'OID003AID002'
          switch_session

          expect_status_to_eq 404
        end
      end
    end

    context 'Organization have banned status' do
      let(:sign_params) do
        {
          email: 'admin@barong.io',
          password: 'testPassword111'
        }
      end

      let!(:banned_organizations) do
        create(:organization, id: 7, oid: 'OID003', parent_organization: nil, name: 'Company C')
        create(:organization, id: 8, oid: 'OID003AID001', parent_organization: 7, name: 'Group C1')
        create(:organization, id: 9, oid: 'OID003AID002', parent_organization: 7, name: 'Group C2', status: 'banned')
      end

      it 'can switch to organization Company C' do
        params[:oid] = 'OID003'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID003')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID003')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')
        expect(session.instance_variable_get(:@delegate)[:role]).to eq('org-admin')
        expect(session.instance_variable_get(:@delegate)[:user_role]).to eq('admin')

        result = JSON.parse(response.body)
        expect(result['organization']['name']).to eq 'Company C'
        expect(result['organization']['subunit']).to eq nil
      end

      it 'can switch to subunit Group C1' do
        params[:oid] = 'OID003AID001'
        switch_session

        expect_status_to_eq 200
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq('OID003AID001')
        expect(session.instance_variable_get(:@delegate)[:oid]).to eq('OID003')
        expect(session.instance_variable_get(:@delegate)[:rid]).to eq('IDFE09081060')

        result = JSON.parse(response.body)
        expect(result['organization']['subunit']['name']).to eq 'Group C1'
      end

      it 'cannot switch to subunit Group C2' do
        params[:oid] = 'OID003AID002'
        switch_session

        expect_status_to_eq 404
      end
    end
  end
end
