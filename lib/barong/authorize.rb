# frozen_string_literal: true

require 'barong/activity_logger'

module Barong
  # AuthZ functionality
  class Authorize
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

    # init base request info, fetch black and white lists
    def initialize(request, path)
      @request = request
      @path = path
      @rules = lists['rules']
    end

    # main: switch between cookie and api key logic, return bearer token
    def auth
      auth_type = 'cookie'
      auth_type = 'api_key' if api_key_headers?
      auth_owner = method("#{auth_type}_owner").call
      'Bearer ' + codec.encode(auth_owner.as_payload) # encoded user info
    end

    # cookies validations
    def cookie_owner
      validate_csrf!

      error!({ errors: ['authz.invalid_session'] }, 401) unless session[:uid]

      user = User.find_by!(uid: session[:uid])
      Rails.logger.debug "User #{user} authorization via cookies"

      validate_session!

      unless user.state.in?(%w[active pending])
        error!({ errors: ['authz.user_not_active'] }, 401)
      end

      validate_permissions!(user)

      user # returns user(whose session is inside cookie)
    end

    def validate_session!
      unless @request.env['HTTP_USER_AGENT'] == session[:user_agent] &&
             Time.now.to_i < session[:expire_time] &&
             find_ip.include?(remote_ip)
        session.destroy
        Rails.logger.debug("Session mismatch! Valid session is: { agent: #{session[:user_agent]}," \
                           " expire_time: #{session[:expire_time]}, ip: #{session[:user_ip]} }," \
                           " but request contains: { agent: #{@request.env['HTTP_USER_AGENT']}, ip: #{remote_ip} }")

        error!({ errors: ['authz.client_session_mismatch'] }, 401)
      end

      session[:expire_time] = Time.now.to_i + Barong::App.config.session_expire_time
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

      validate_permissions!(user)

      user # returns user(api key creator)
    rescue ActiveRecord::RecordNotFound
      error!({ errors: ['authz.unexistent_apikey'] }, 401)
    end

    def validate_csrf!
      return unless Barong::App.config.csrf_protection && @request.env['REQUEST_METHOD'].in?(STATE_CHANGING_VERBS)

      unless headers['X-CSRF-Token']
        Rails.logger.info("CSRF attack warning! Missing token for uid: #{session[:uid]} in request to #{@path} by #{@request.env['REQUEST_METHOD']}")
        error!({ errors: ['authz.missing_csrf_token'] }, 401)
      end

      unless headers['X-CSRF-Token'] == session[:csrf_token]
        Rails.logger.info("CSRF attack warning! Token is not valid for uid: #{session[:uid]} in request to #{@path} by #{@request.env['REQUEST_METHOD']}")
        error!({ errors: ['authz.csrf_token_mismatch'] }, 401)
      end
    end

    def validate_permissions!(user)
      # Caches Permission.all result to optimize
      permissions = Rails.cache.fetch('permissions', expires_in: 5.minutes) { Permission.all.to_ary }

      permissions.select! { |a| a.role == user.role && ( a.verb == @request.env['REQUEST_METHOD'] || a.verb == 'ALL' ) && @path.starts_with?(a.path) }
      actions = permissions.blank? ? [] : permissions.pluck(:action).uniq

      if permissions.blank? || actions.include?('DROP') || !actions.include?('ACCEPT')
        log_activity(user.id, 'denied') if user.is_a?(User)
        error!({ errors: ['authz.invalid_permission'] }, 401)
      end

      if actions.include?('AUDIT')
        topic = permissions.select { |a| a.action == 'AUDIT' }[0].topic
        log_activity(user.id, 'succeed', topic) if user.is_a?(User)
      end
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

    # encode helper method
    def codec
      @_codec ||= Barong::JWT.new(key: Barong::App.config.keystore.private_key)
    end

    # fetch authz rules from yml
    def lists
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
        error!({ errors: ['authz.invalid_session'] }, 401)
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
  end
end
