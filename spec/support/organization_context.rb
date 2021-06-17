# frozen_string_literal: true

shared_context 'organization memberships' do
  let!(:create_permissions) do
    create(:permission, role: 'superadmin')
    create(:permission, role: 'admin')
    create(:permission, role: 'member')
    create(:permission, role: 'org-admin')
    create(:permission, role: 'org-member')
    create(:permission, role: 'org-accountant')
    create(:permission, role: 'technical')
  end

  let!(:mock_users) do
    create(:user, id: 1, uid: 'IDFE09081060', email: 'admin@barong.io', password: 'testPassword111',
                  password_confirmation: 'testPassword111', role: 'admin', state: 'active')
    create(:user, id: 2, uid: 'IDFE10A90000', email: 'adminA@barong.io', password: 'testPassword111',
                  password_confirmation: 'testPassword111', role: 'org-admin', state: 'active')
    create(:user, id: 3, uid: 'IDFE10A90001', email: 'memberA1@barong.io', password: 'testPassword111',
                  password_confirmation: 'testPassword111', role: 'org-member', state: 'active')
    create(:user, id: 4, uid: 'IDFE10A90002', email: 'memberA2@barong.io', password: 'testPassword111',
                  password_confirmation: 'testPassword111', role: 'org-member', state: 'active')
    create(:user, id: 5, uid: 'IDFE10B90001', email: 'memberB1@barong.io', password: 'testPassword111',
                  password_confirmation: 'testPassword111', role: 'org-member', state: 'active')
    create(:user, id: 6, uid: 'IDFE10A90003', email: 'memberA1A2@barong.io', password: 'testPassword111',
                  password_confirmation: 'testPassword111', role: 'org-member', state: 'active')
    create(:user, id: 7, uid: 'IDFE0908101', email: 'user1@barong.io', password: 'testPassword111',
                  password_confirmation: 'testPassword111', role: 'member', state: 'active')
    create(:user, id: 8, uid: 'IDFE0000000', email: 'superadmin@barong.io', password: 'testPassword111',
                  password_confirmation: 'testPassword111', role: 'superadmin', state: 'active')
    create(:user, id: 9, uid: 'IDFE10AA000', email: 'org.accountant@barong.io', password: 'testPassword111',
                  password_confirmation: 'testPassword111', role: 'org-accountant', state: 'active')
    create(:user, id: 10, uid: 'IDFE10UNATV', email: 'unactivate@barong.io', password: 'testPassword111',
                  password_confirmation: 'testPassword111', role: 'org-accountant', state: 'pending')
    create(:user, id: 11, uid: 'IDADMINUNOG', email: 'unorgadmin@barong.io', password: 'testPassword111',
                  password_confirmation: 'testPassword111', role: 'org-admin', state: 'active')
    create(:user, id: 12, uid: 'ID_UNPERMITTED_SS', email: 'unpermitted_switch_session@barong.io', password: 'testPassword111',
                  password_confirmation: 'testPassword111', role: 'technical', state: 'active')
  end

  let!(:mock_organizations) do
    create(:organization, id: 1, oid: 'OID001', parent_organization: nil, name: 'Company A')
    create(:organization, id: 2, oid: 'OID002', parent_organization: nil, name: 'Company B')
    create(:organization, id: 3, oid: 'OID001AID001', parent_organization: 1, name: 'Group A1')
    create(:organization, id: 4, oid: 'OID001AID002', parent_organization: 1, name: 'Group A2')
    create(:organization, id: 5, oid: 'OID002AID001', parent_organization: 2, name: 'Group B1')
    create(:organization, id: 6, oid: 'OID002AID002', parent_organization: 2, name: 'Group B2')
  end

  let!(:mock_profiles) do
    create(:profile, user_id: 2, first_name: 'UserFirstName', last_name: 'UserLastName', state: 'verified')
    create(:label, user_id: 2, key: 'email', value: 'verified', scope: 'private')
    create(:profile, user_id: 7, first_name: 'UserFirstName', last_name: 'UserLastName', state: 'verified')
    create(:label, user_id: 7, key: 'email', value: 'verified', scope: 'private')
    create(:profile, user_id: 9, first_name: 'UserFirstName', last_name: 'UserLastName', state: 'submitted')
    create(:label, user_id: 9, key: 'email', value: 'verified', scope: 'private')
  end
end
