# frozen_string_literal: true

# Full list of roles abilities could be found on docs/roles.md
class Ability
  include CanCan::Ability

  def initialize(user)
    return if Ability.permissions[user.role].nil?

    # Iterate through member permissions
    Ability.permissions[user.role].each do |action, models|
      # Iterate through a list of member model access
      models.each do |model|
        can action.to_sym, model == 'all' ? model.to_sym : model.constantize
      end
    end
  end

  class << self
    def permissions
      @permissions ||= Ability.load_abilities
      @permissions['permissions']
    end

    def load_abilities(file = 'abilities.yml')
      YAML.load_file("#{Rails.root}/config/#{file}")
    end
  end
end
