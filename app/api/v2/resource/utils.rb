# frozen_string_literal: true

module API::V2
  module Resource
    module Utils
      def current_user
        # To identiy origin user by env[:current_payload][:rid]
        # if exist, user comes from switched mode use env[:current_payload][:rid]; else use [:uid]
        if env[:current_payload].key?(:rid)
          uid = env[:current_payload][:rid]
        elsif env[:current_payload].key?(:uid)
          uid = env[:current_payload][:uid]
        else
          raise(Peatio::Auth::Error, 'Middleware Error')
        end
        @_current_user ||= User.find_by!(uid: uid)

        # Set role with current switched user
        @_current_user.role = env[:current_payload][:role] if env[:current_payload].key?(:role)
        @_current_user
      end

      def current_organization
        if env[:current_payload].key?(:oid) && !env[:current_payload][:oid].nil?
          # Determine organization from session first
          ::Organization.find_by!(oid: env[:current_payload][:oid])
        else
          # User logged in as individual mode. Find user in organization
          memberships = current_user.memberships
          return nil if memberships.nil? || memberships.empty? || memberships.first.organization_id.zero?

          # Find root organization
          org = memberships.first.organization
          if org.parent_organization.nil?
            org
          else
            ::Organization.find(org.parent_organization)
          end
        end
      end

      def record_error!(options = {})
        options[:data] = { reason: options[:reason] }.to_json
        options[:result] = 'failed'
        activity_record(options.except(:reason, :error_code))
        error!({ errors: ['resource.' + options[:topic] + '.' + options[:error_text]] }, options[:error_code])
      end

      def twilio_dictionary_error(code)
        user_error = 'resource.phone.' + {
          21_612 => 'num_not_reachable',
          21_614 => 'num_not_valid',
          21_618 => 'sms_content_invalid',
          21_610 => 'unsubscribed_recipient'
        }[code]

        user_error || 'resource.phone.twilio_unexpected'
      end

      def activity_record(options = {})
        params = {
          category:        'user',
          user_id:         options[:user],
          user_ip:         remote_ip,
          user_ip_country: Barong::GeoIP.info(ip: remote_ip, key: :country),
          user_agent:      request.env['HTTP_USER_AGENT'],
          topic:           options[:topic],
          action:          options[:action],
          result:          options[:result],
          data:            options[:data]
        }
        Activity.create(params)
      end

      def password_valid?(password)
        true if current_user == current_user.try(:authenticate, password)
      end
    end
  end
end
