# frozen_string_literal: true

module API::V2
  module Utils
    def remote_ip
      # default behaviour, IP from HTTP_X_FORWARDED_FOR
      ip = env['action_dispatch.remote_ip'].to_s

      if Barong::App.config.gateway == 'akamai'
        # custom header that contains only client IP
        true_client_ip = request.env['HTTP_TRUE_CLIENT_IP'].to_s
        # take IP from TRUE_CLIENT_IP only if its not nil or empty
        ip = true_client_ip unless true_client_ip.nil? || true_client_ip.empty?
      end

      Rails.logger.debug "User login IP address: #{ip}"
      ip
    end

    def code_error!(errors, code)
      final = errors.inject([]) do |result, (key, errs)|
        result.concat(
          errs.map { |e| e.values.first }
                .uniq
                .flatten
                .map { |e| [key, e].join('.') }
        )
      end
      error!({ errors: final }, code)
    end

    def admin_authorize!(*args)
      AdminAbility.new(current_user).authorize!(*args)
    rescue CanCan::AccessDenied
      error!({ errors: ['admin.ability.not_permitted'] }, 401)
    end

    def admin_organization_authorize!(*_args)
      error!({ errors: ['identity.member.not_found'] }, 404) unless admin_organization?
    rescue CanCan::AccessDenied
      error!({ errors: ['organization.ability.not_permitted'] }, 401)
    end

    def organization_authorize!(*_args)
      error!({ errors: ['organization.ability.not_permitted'] }, 401) if current_organization.nil?

      members = Membership.where(user_id: current_user.id, organization_id: current_organization.id)

      # User is not organization admin
      error!({ errors: ['organization.ability.not_permitted'] }, 401) if members.nil? || members.length.zero?
    rescue CanCan::AccessDenied
      error!({ errors: ['organization.ability.not_permitted'] }, 401)
    end

    def admin_organization?
      # Check user is barong organization admin or not
      members = Membership.joins('LEFT JOIN organizations ON organizations.id = memberships.organization_id')
                          .where(user_id: current_user.id, organization_id: 0)
      !members.nil? && !members.length.zero?
    end
  end
end
