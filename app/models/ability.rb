# frozen_string_literal: true

# Full list of roles abilities could be found on docs/roles.md
class Ability
  class << self
    def abilities
      @abilities ||= YAML.load_file("#{Rails.root}/config/abilities.yml")
    end

    def admin_permissions
      abilities['admin_permissions']
    end

    def organization_permissions
      abilities['organization_permissions']
    end

    def roles
      roles = abilities['roles']
      roles.concat(organization_roles)
    end

    def organization_roles
      abilities['organization_roles'] || []
    end
  end
end
