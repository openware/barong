# frozen_string_literal: true

describe Ability do
  before do
    allow(Ability).to receive(:roles).and_return(%w[
                                                   superadmin
                                                   admin
                                                   technical
                                                   accountant
                                                   compliance
                                                   support
                                                 ])

    allow(Ability).to receive(:organization_roles).and_return(%w[
                                                                org-admin
                                                                org-member
                                                                org-accountant
                                                              ])
  end

  let!(:create_permissions) do
    create(:permission, role: 'superadmin', action: 'accept', verb: 'get')
    create(:permission, role: 'admin', action: 'accept', verb: 'get')
    create(:permission, role: 'compliance', action: 'accept', verb: 'get')
    create(:permission, role: 'support', action: 'accept', verb: 'get')
    create(:permission, role: 'org-admin', action: 'accept', verb: 'get')
    create(:permission, role: 'org-member', action: 'accept', verb: 'get')
    create(:permission, role: 'org-accountant', action: 'accept', verb: 'get')
  end

  context 'abilities roles' do
    it 'should display organization_roles' do
      roles = Ability.organization_roles

      expect(roles.length).to eq(3)
    end

    it 'should display roles' do
      roles = Ability.roles
      roles.concat(Ability.organization_roles)

      expect(roles.length).to eq(9)
    end
  end
end
