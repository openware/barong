# frozen_string_literal: true

require 'barong/activity_logger'
require 'barong/sys_jwt'

module Barong
  # AuthZ functionality
  class Authorize
    include API::V2::Identity::Utils

    STATE_CHANGING_VERBS = %w[POST PUT PATCH DELETE TRACE].freeze
    # Custom Error class to support error status and message
    class AuthError < StandardError
      attr_reader :code

      # init an error with status and text to return in api response
      def initialize(code)
        super
        @code = code
      end
    end

    attr_reader :request
    # init base request info, fetch black and white lists
    def initialize(request, path)
      @request = request
      @path = path
      @rules = lists['rules']
    end

    def uid
      @auth_owner.uid
    end

    def rate_limit_level
      @auth_owner.rate_limit_level || 0
    end

    # main: switch between cookie and api key logic, return bearer token
    def auth
      'Bearer ' + bearer
    end

    def auth_owner
      auth_type = 'cookie'
      auth_type = 'api_key' if api_key_headers?
      @auth_owner = method("#{auth_type}_owner").call
    end

    def cookie_owner
      validate_csrf!

      if session.claims.present? && session.claims.key?('email')
        error!({ errors: ['identity.session.auth0.invalid_params'] }, 401) unless session.claims.key?('email')
        user = User.find_by(email: session.claims['email'])
        # If there is no user in platform and user email verified from id_token
        # system will create user
        if user.blank? && session.claims['email_verified']
          user = User.create!(email: session.claims['email'], state: 'active')
          user.labels.create!(scope: 'private', key: 'email', value: 'verified')
        elsif session.claims['email_verified'] == false
          error!({ errors: ['identity.session.auth0.email_not_verified'], email: session.claims['email'] }, 401) unless user
        end

        # авторизация прошла напрямую в barong, через логин-пароль
      elsif session.key?(:barong_uid) && ENV.true?('DIRECT_AUTH')
        user = User.find_by(uid: session[:barong_uid])
        error!({ errors: ['authz.invalid_session', 'no_barong_uid'] }, 401) if user.nil?
      else
        error!({ errors: ['authz.invalid_session', 'no_barong_uid_or_claims'] }, 401)
      end

      validate_session!
      unless user.state.in?(%w[active pending])
        error!({ errors: ['authz.user_not_active'] }, 401)
      end

      open_session(user) unless user.id == session[:barong_uid]
      validate_bitzlato_user!(user)
      validate_permissions!(user)

      user
    end

    def validate_session!
      unless ENV.true?( 'SKIP_SESSION_INVALIDATION' )
        unless user_agent == session[:user_agent] &&
            Time.now.to_i < session[:expire_time] &&
            find_ip.include?(remote_ip)

          # Delete session from additional redis list
          Barong::RedisSession.delete(session[:barong_uid], session.id.to_s)

          session.destroy

          Rails.logger.warn("Session mismatch! Valid session is: { agent: #{session[:user_agent]}," \
                            " expire_time: #{session[:expire_time]}, ip: #{session[:user_ip]} }," \
                            " but request contains: { agent: #{@request.env['HTTP_USER_AGENT']}, ip: #{remote_ip} }")

          error!({ errors: ['authz.client_session_mismatch'] }, 401)
        end
      end

      # Update session key expiration date
      session[:expire_time] = Time.now.to_i + Barong::App.config.session_expire_time
      Barong::RedisSession.update(session[:barong_uid], session.id.to_s, session[:expire_time])
    end

    def find_ip
      ip_addr = IPAddr.new(session[:user_ip])
      if ip_addr.ipv4?
        ip_addr.mask(16)
      else
        ip_addr.mask(96)
      end
    end

    # api key validations
    def api_key_owner
      api_key = APIKeysVerifier.new(api_key_params)

      # validate that nonce is a positive integer
      error!({ errors: ['authz.nonce_not_valid_timestamp'] }, 401) if api_key_params[:nonce].to_i <= 0
      # timestamp_window is a difference between server_time and nonce creation time
      nonce_timestamp_window = ((Time.now.to_f * 1000).to_i - api_key_params[:nonce].to_i).abs
      Rails.logger.debug("Api key authorization via key: #{api_key_params[:kid]} to path #{@path} \
                          with nonce: #{api_key_params[:nonce]} in a window of #{nonce_timestamp_window}")
      # (server_time - nonce) should not be more than nonce lifetime
      error!({ errors: ['authz.nonce_expired'] }, 401) if nonce_timestamp_window >= Barong::App.config.apikey_nonce_lifetime
      # signature should be valid
      error!({ errors: ['authz.invalid_signature'] }, 401) unless api_key.verify_hmac_payload?

      current_api_key = APIKey.find_by_kid(api_key_params[:kid])
      # corresponding Api Key should be active
      error!({ errors: ['authz.apikey_not_active'] }, 401) unless current_api_key.active?

      # here User is either User object or ServiceAccount object
      user = current_api_key.key_holder_account
      validate_user!(user)
      validate_bitzlato_user!(user)
      validate_permissions!(user)

      user # returns user(api key creator)
    rescue ActiveRecord::RecordNotFound
      error!({ errors: ['authz.unexistent_apikey'] }, 401)
    end

    def validate_bitzlato_user!(user)
      return unless ENV.true? 'USE_BITZLATO_AUTHORIZATION'
      bitzlato_user = user.bitzlato_user
      # TODO make asyn request to https://bitzlato.com/api/p2p/whoami to generate user
      return if bitzlato_user.nil?
      if bitzlato_user.user_profile.try(&:blocked_by_admin?)
        Rails.logger.warn("Bitzlato user #{bitzlato_user.real_email} is blocked by admin")
        error!({ errors: ['authz.blocked_account'] }, 401)
      end
    end

    def validate_csrf!
      return unless Barong::App.config.csrf_protection && @request.env['REQUEST_METHOD'].in?(STATE_CHANGING_VERBS)

      unless headers['X-CSRF-Token']
        Rails.logger.info("CSRF attack warning! Missing token for uid: #{session[:barong_uid]} in request to #{@path} by #{@request.env['REQUEST_METHOD']}")
        error!({ errors: ['authz.missing_csrf_token'] }, 401)
      end

      unless headers['X-CSRF-Token'] == session[:csrf_token]
        Rails.logger.info("CSRF attack warning! Token is not valid for uid: #{session[:barong_uid]} in request to #{@path} by #{@request.env['REQUEST_METHOD']}")
        error!({ errors: ['authz.csrf_token_mismatch'] }, 401)
      end
    end

    def validate_permissions!(user)
      # Caches Permission.all result to optimize
      permissions = Rails.cache.fetch('permissions', expires_in: 5.minutes) { Permission.all.to_ary }

      permissions.select! do |permission|
        (!permission.respond_to?(:domain) || permission.domain == request_domain) &&
          (permission.role == Permission::ANY_ROLE || permission.role == user.role) &&
          (permission.verb == @request.env['REQUEST_METHOD'] || permission.verb == 'ALL' ) &&
          (permission.path == Permission::ANY_PATH || @path.starts_with?(permission.path))
      end

      actions = permissions.blank? ? [] : permissions.pluck(:action).uniq

      if permissions.blank? || actions.include?('DROP') || !actions.include?('ACCEPT')
        Rails.logger.debug("auth.invalid_permission: permissions.blank?=#{permissions.blank?}, actions.include?('DROP')=#{actions.include?('DROP')}, !actions.include?('ACCEPT')=#{!actions.include?('ACCEPT')}")
        log_activity(user.id, 'denied') if user.is_a?(User)
        error!({ errors: ['authz.invalid_permission'] }, 401)
      end

      if actions.include?('AUDIT')
        topic = permissions.select { |a| a.action == 'AUDIT' }[0].topic
        log_activity(user.id, 'succeed', topic) if user.is_a?(User)
      end
    end

    def request_domain
      @request_domain ||= DomainHost.find_by(host: @request.env['HTTP_HOST'] || @request.env['SERVER_ADDR']).try(:domain) ||
        ENV.fetch('UNKNOWN_PERMISSION_DOMAIN', DomainHost::DEFAULT_DOMAIN)
    end

    def log_activity(user_id, result, topic = nil)
      if Rails.env.test?
        ActivityLogger.sync_write(activity_params(user_id, result, topic))
      else
        ActivityLogger.async_write(activity_params(user_id, result, topic))
      end
    end

    def activity_params(user_id, result, topic)
      {
        user_id: user_id,
        result: result,
        user_agent: @request.env['HTTP_USER_AGENT'],
        user_ip: remote_ip,
        user_ip_country: Barong::GeoIP.info(ip: remote_ip, key: :country),
        path: @path,
        topic: topic,
        verb: @request.env['REQUEST_METHOD'],
        payload: @request.params
      }
    end

    # black/white list validation. takes ['block', 'pass'] as a parameter
    def under_path_rules?(type)
      return false if @rules[type].nil? # if no authz rules provided

      @rules[type].each do |t|
        return true if @path.starts_with?(t) # if request path is inside the rules list
      end
      false # default
    end

    def user_agent
      @request.env['HTTP_USER_AGENT']
    end

    def remote_ip
      # default behaviour, IP from HTTP_X_FORWARDED_FOR
      ip = @request.remote_ip

      if Barong::App.config.gateway == 'akamai'
        # custom header that contains only client IP
        true_client_ip = @request.env['HTTP_TRUE_CLIENT_IP']
        # take IP from TRUE_CLIENT_IP only if its not nil or empty
        ip = true_client_ip unless true_client_ip.nil? || true_client_ip.empty?
      end

      return ip
    end

    private

    def use_sys_jwk?
      request_domain == ENV.fetch('SYS_JWK_DOMAIN', 'p2p')
    end

    def bearer
      Rails.logger.warn("request_domain = #{request_domain}, path = #{path}, #{@request.env['HTTP_HOST']}, #{@request.env['SERVER_ADDR']}")
      if use_sys_jwk?
        Rails.logger.warn("Use sys jwk")
        owner = auth_owner
        raise "Wrong auth_owner type (#{owner.class})" unless owner.is_a? User
        raise "No bitzlato user for #{owner.as_payload}" unless owner.bitzlato_user.present?
        sys_codec.
          encode(owner.bitzlato_user.as_payload)
      else
        codec.
          encode(auth_owner.as_payload)
      end
    end

    def sys_codec
      @sys_codec ||= Barong::SysJWT.new
    end

    def codec
      @codec ||= Barong::JWT.
        new(key: Barong::App.config.keystore.private_key)
    end

    # fetch authz rules from yml
    def lists
      # TODO domains
      YAML.safe_load(
        ERB.new(
          File.read(
            Barong::App.config.authz_rules_file
          )
        ).result
      )
    end

    # checks if api key headers are present in request
    def api_key_headers?
      return false if headers['X-Auth-Apikey'].nil? &&
        headers['X-Auth-Nonce'].nil? &&
        headers['X-Auth-Signature'].nil?
      @api_key_headers = [headers['X-Auth-Apikey'], headers['X-Auth-Nonce'], headers['X-Auth-Signature']]
      validate_headers?
    end

    def validate_user!(user)
      unless user.state.in?(%w[active pending])
        error!({ errors: ['authz.user_not_active'] }, 401)
      end

      if user.is_a?(User) && !user.otp
        error!({ errors: ['authz.disabled_2fa'] }, 401)
      end
    end

    # api key headers nil, blank validation
    def validate_headers?
      @api_key_headers.each do |k|
        error!({ errors: ['authz.invalid_api_key_headers'] }, 422) if k.blank?
      end
    end

    # converts header into hash of parameters
    def api_key_params
      {
        'kid': headers['X-Auth-Apikey'],
        'nonce': headers['X-Auth-Nonce'],
        'signature':  headers['X-Auth-Signature']
      }
    end

    # custom error, calls AuthError class
    def error!(text, code)
      Rails.logger.debug "Error raised with code #{code} and error message #{text.to_json}"
      raise AuthError.new(code),  text.to_json
    end

    def headers
      @request.headers
    end

    def session
      @request.session
    end

    def cookies
      @request.cookies
    end
  end
end
