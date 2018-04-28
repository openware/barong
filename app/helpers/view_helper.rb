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

  def label_tags(account)
    account.labels.map { |l| "#{l.key}:#{l.value}" }.join(', ')
  end

  def self.with_frontend_domain(params)
    frontend_domain = ENV['FRONTEND_DOMAIN']
    return params if frontend_domain.blank?
    params.merge(host: frontend_domain)
  end
end
