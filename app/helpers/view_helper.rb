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

end
