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

    def roles
      abilities['roles']
    end
  end
end
