# frozen_string_literal: true

module API::V2
  module Resource
    module Utils
      def current_user
        if env[:current_payload].has_key?(:uid)
          @_current_user ||= User.find_by!(uid: env[:current_payload][:uid])
        else
          raise(Peatio::Auth::Error, 'Middleware Error')
        end
      end

      def unified_params
        params.merge!(kid: SecureRandom.hex(8)) if params[:algorithm].include?('HS')
        params
      end

      def record_error!(options = {})
        options[:data] = { reason: options[:reason] }.to_json
        options[:result] = 'failed'
        activity_record(options.except(:reason, :error_code))
        error!({ errors: ['resource.' + options[:topic] + '.' + options[:error_text]] }, options[:error_code])
      end

      def activity_record(options = {})
        params = {
          user_id:    options[:user],
          user_ip:    request.ip,
          user_agent: request.env['HTTP_USER_AGENT'],
          topic:      options[:topic],
          action:     options[:action],
          result:     options[:result],
          data:       options[:data]
        }
        Activity.create(params)
      end

      def password_valid?(password)
        true if current_user == current_user.try(:authenticate, password)
      end
    end
  end
end
