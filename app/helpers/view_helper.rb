# frozen_string_literal: true

module ViewHelper
  def badge_by_state(state)
    case state
      when 'created'
        'info'
      when 'pending'
        'primary'
      when 'approved'
        'success'
      when 'rejected'
        'danger'
    end
  end

  def badge_by_role(role)
    case role
      when 'admin'
        'badge-success'
      when 'compliance'
        'badge-warning'
      when 'member'
        'badge-info'
    end
  end
end
