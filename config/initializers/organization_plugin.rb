# frozen_string_literal: true

module OrganizationPlugin
  ADMIN_SWITCH_SESSION_AUTHORIZED_ROLES = JSON.parse(ENV.fetch('BARONG_ORG_ADMIN_SWITCH_SESSION_AUTHORIZED_ROLES')) rescue ['member', 'org-admin', 'org-member', 'org-accountant']
  
  def self.check_authoirzed_role_for_admin_switch_session(role)
    OrganizationPlugin::ADMIN_SWITCH_SESSION_AUTHORIZED_ROLES.include? role
  end
end
