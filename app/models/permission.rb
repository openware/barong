# frozen_string_literal: true

# Permissions model for RBAC
class Permission < ApplicationRecord
  validates :role, :verb, :action, :path, presence: true

  before_validation :upcase_action_verb

  private

  def upcase_action_verb
    return if action.blank? || verb.blank?

    self.action.upcase!
    self.verb.upcase!
  end
end
