# frozen_string_literal: true

#
# Generated by CanCanCan via "bundle exec rails g cancan:ability".
#
class Ability
  include CanCan::Ability

  def initialize(account)
    case account.role
      when 'admin'
        can :manage, :all
      when 'compliance'
        can :manage,  [Profile]
        can :read,    [Account]
    end
  end
end
