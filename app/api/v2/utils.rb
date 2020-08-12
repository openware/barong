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
      return ip
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
  end
end
