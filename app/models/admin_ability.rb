# frozen_string_literal: true

class AdminAbility
  include CanCan::Ability

  def initialize(user)
    return if Ability.admin_permissions[user.role].nil?

    # Iterate through user permissions
    Ability.admin_permissions[user.role].each do |action, models|
      # Iterate through a list of user model access
      models.each do |model|
        can action.to_sym, model == 'all' ? model.to_sym : model.constantize
      end
    end
  end
end
