# frozen_string_literal: true

module API::V2
  module Identity
    module Utils

      def session
        request.session
      end

      def codec
        @_codec ||= Barong::JWT.new(key: Barong::App.config.keystore.private_key)
      end

      def verify_captcha!(user:, response:, error_statuses: [400, 422])
        captcha_error_message = 'reCAPTCHA verification failed, please try again.'
        error!('recaptcha_response is required', error_statuses.first) if response.blank?
        return if RecaptchaVerifier.new(request: request).verify_recaptcha(model: user,
                                                                          skip_remote_ip: true,
                                                                          response: response)
        error!(captcha_error_message, error_statuses.last)
      rescue StandardError
        error!(captcha_error_message, error_statuses.last)
      end

      def apikey_headers?
        return false if headers['X-Auth-Apikey'].nil? &&
        headers['X-Auth-Nounce'].nil? &&
        headers['X-Auth-Signature'].nil?
        @apikey_headers = [headers['X-Auth-Apikey'], headers['X-Auth-Nounce'], headers['X-Auth-Signature']]
        validate_headers?
      end

      def validate_headers?
        @apikey_headers.each do |k|
          error!('Request contains invalid or blank api key headers!') if k.blank?
        end
      end

      def apikey_params
        params = {}
        params.merge(
          'kid': headers['X-Auth-Apikey'],
          'nounce': headers['X-Auth-Nounce'],
          'signature':  headers['X-Auth-Signature']
        )
      end

      def login_error!(options = {})
        session_activity(options.except(:reason, :error_code))
        error!(options[:reason], options[:error_code])
      end

      def session_activity(options = {})
        params = {
          user_id:    options[:user],
          user_ip:    request.ip,
          user_agent: request.env['HTTP_USER_AGENT'],
          topic:      'session',
          action:     options[:action],
          result:     options[:result],
          data:       options[:data]
        }
        Activity.create(params)
      end

      def confirmation_codec
        @_codec ||= Barong::JWT.new(key: Barong::App.config.keystore.private_key, sub: 'confirmation')
      end
    end
  end
end
