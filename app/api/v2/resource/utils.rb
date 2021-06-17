# frozen_string_literal: true

module API::V2
  module Resource
    module Utils
      def current_user
        # To identiy origin user by env[:current_payload][:rid]
        oid = nil
        if env[:current_payload].key?(:oid)
          uid = if env[:current_payload][:oid].nil?
                  # switch as user
                  env[:current_payload][:uid]
                else
                  # switch as organization
                  oid = env[:current_payload][:uid]
                  env[:current_payload][:rid]
                end
        elsif env[:current_payload].key?(:uid)
          uid = env[:current_payload][:uid]
        else
          raise(Peatio::Auth::Error, 'Middleware Error')
        end
        @_current_user ||= User.find_by!(uid: uid)

        # Set role with current switched user
        role = env[:current_payload].key?(:role) ? env[:current_payload][:role] : @_current_user.role
        user_role = env[:current_payload].key?(:user_role) ? env[:current_payload][:user_role] : @_current_user.role
        @_current_user.role = role
        @_current_user.current_user_role = user_role
        @_current_user.current_oid = oid
        @_current_user
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
          category: 'user',
          user_id: options[:user],
          user_ip: remote_ip,
          user_ip_country: Barong::GeoIP.info(ip: remote_ip, key: :country),
          user_agent: request.env['HTTP_USER_AGENT'],
          topic: options[:topic],
          action: options[:action],
          result: options[:result],
          data: options[:data]
        }
        Activity.create(params)
      end

      def password_valid?(password)
        true if current_user == current_user.try(:authenticate, password)
      end
    end
  end
end
