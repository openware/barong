# frozen_string_literal: true

module API::V2
  module Identity
    module Utils
      def session
        request.session_options[:expire_after] = Barong::App.config.session_expire_time.to_i.seconds
        request.session
      end

      def codec
        @_codec ||= Barong::JWT.new(key: Barong::App.config.keystore.private_key)
      end

      def verify_captcha!(user:, response:, error_statuses: [400, 422])
        return if Barong::CaptchaPolicy.config.disabled

        if response.blank?
          error!('captcha_response is required', error_statuses.first)
        end

        if Barong::CaptchaPolicy.config.re_captcha
          recaptcha(user: user, response: response)
        end
        geetest(response: response) if Barong::CaptchaPolicy.config.geetest_captcha
      end

      def recaptcha(user:, response:, error_statuses: [400, 422])
        captcha_error_message = 'reCAPTCHA verification failed, please try again.'

        return if CaptchaService::RecaptchaVerifier.new(request: request).verify_recaptcha(model: user,
                                                                           skip_remote_ip: true,
                                                                           response: response)

        error!(captcha_error_message, error_statuses.last)
      rescue StandardError
        error!(captcha_error_message, error_statuses.last)
      end

      def geetest(response:, error_statuses: [400, 422])
        geetest_error_message = 'Geetest verification failed, please try again.'
        validate_geetest_response(response: response)

        return if CaptchaService::GeetestVerifier.new.validate(response)

        error!(geetest_error_message, error_statuses.last)
      rescue StandardError
        error!(geetest_error_message, error_statuses.last)
      end

      def validate_geetest_response(response:)
        unless (response['geetest_challenge'].is_a? String) &&
               (response['geetest_validate'].is_a? String) &&
               (response['geetest_seccode'].is_a? String)
          error!('mandatory fields must be filled in', 400)
        end
      end

      def login_error!(options = {})
        options[:data] = { reason: options[:reason] }.to_json
        options[:topic] = 'session'
        activity_record(options.except(:reason, :error_code))
        error!(options[:reason], options[:error_code])
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

      def token_uniq?(jti)
        error!('JWT has already been used') if Rails.cache.read(jti) == 'utilized'
        Rails.cache.write(jti, 'utilized')
      end

      def publish_confirmation(user)
        token = codec.encode(sub: 'confirmation', email: user.email, uid: user.uid)
        EventAPI.notify(
          'system.user.email.confirmation.token',
          user: user.as_json_for_event_api,
          token: token
        )
      end
    end
  end
end
