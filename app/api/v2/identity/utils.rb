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

      def open_session(user)
        csrf_token = SecureRandom.hex(10)
        expire_time = Time.now.to_i + Barong::App.config.session_expire_time
        session.merge!(
          "uid": user.uid,
          "user_ip": remote_ip,
          "user_agent": request.env['HTTP_USER_AGENT'],
          "expire_time": expire_time,
          "csrf_token": csrf_token
        )

        # Add current session key info in additional redis list
        Barong::RedisSession.add(user.uid, session.id.to_s, expire_time)

        csrf_token
      end

      def verify_captcha!(response:, endpoint:, error_statuses: [400, 422])
        # by default we protect user_create session_create password_reset email_confirmation endpoints
        return unless BarongConfig.list['captcha_protected_endpoints']&.include?(endpoint)

        case Barong::App.config.captcha
        when 'recaptcha'
          recaptcha(response: response)
        when 'geetest'
          geetest(response: response)
        end
      end

      def recaptcha(response:, error_statuses: [400, 422])
        error!({ errors: ['identity.captcha.required'] }, error_statuses.first) if response.blank?

        captcha_error_message = 'identity.captcha.verification_failed'

        return if CaptchaService::RecaptchaVerifier.new(request: request).response_valid?(skip_remote_ip: true, response: response)

        error!({ errors: [captcha_error_message] }, error_statuses.last)
      rescue StandardError
        error!({ errors: [captcha_error_message] }, error_statuses.last)
      end

      def geetest(response:, error_statuses: [400, 422])
        error!({ errors: ['identity.captcha.required'] }, error_statuses.first) if response.blank?

        geetest_error_message = 'identity.captcha.verification_failed'
        validate_geetest_response(response: response)

        return if CaptchaService::GeetestVerifier.new.validate(response)

        error!({ errors: [geetest_error_message] }, error_statuses.last)
      rescue StandardError
        error!({ errors: [geetest_error_message] }, error_statuses.last)
      end

      def validate_geetest_response(response:)
        unless (response['geetest_challenge'].is_a? String) &&
               (response['geetest_validate'].is_a? String) &&
               (response['geetest_seccode'].is_a? String)
          error!({ errors: ['identity.captcha.mandatory_fields'] }, 400)
        end
      end

      def login_error!(options = {})
        options[:data] = { reason: options[:reason] }.to_json
        options[:topic] = 'session'
        activity_record(options.except(:reason, :error_code, :error_text))
        error!({ errors: ['identity.session.' + options[:error_text]] }, options[:error_code])
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

      def token_uniq?(jti)
        error!({ errors: ['identity.user.utilized_token'] }, 422) if Rails.cache.read(jti) == 'utilized'
        Rails.cache.write(jti, 'utilized', expires_in: Barong::App.config.jwt_expire_time.seconds)
      end

      def publish_confirmation(user, domain)
        token = codec.encode(sub: 'confirmation', email: user.email, uid: user.uid)
        EventAPI.notify(
          'system.user.email.confirmation.token',
          record: {
            user: user.as_json_for_event_api,
            domain: domain,
            token: token
          }
        )
      end

      def publish_session_create(user)
        EventAPI.notify('system.session.create',
                        record: {
                          user: user.as_json_for_event_api,
                          user_ip: remote_ip,
                          user_agent: request.env['HTTP_USER_AGENT']
                        })
      end
    end
  end
end
