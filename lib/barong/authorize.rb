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
      validate_restrictions!

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
             find_ip.include?(@request.remote_ip)
        session.destroy
        Rails.logger.error("Session mismatch! Valid session is: { agent: #{session[:user_agent]}," \
                           " expire_time: #{session[:expire_time]}, ip: #{session[:user_ip]} }," \
                           " but request contains: { agent: #{@request.env['HTTP_USER_AGENT']}, ip: #{@request.remote_ip} }")

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

      error!({ errors: ['authz.invalid_signature'] }, 401) unless api_key.verify_hmac_payload?

      current_api_key = APIKey.find_by_kid(api_key_params[:kid])
      error!({ errors: ['authz.apikey_not_active'] }, 401) unless current_api_key.active?

      user = User.find_by_id(current_api_key.user_id)
      Rails.logger.info("Api key authorization by user: #{user.email} via key: #{current_api_key.kid}")

      validate_user!(user)

      validate_permissions!(user)

      user # returns user(api key creator)
    rescue ActiveRecord::RecordNotFound
      error!({ errors: ['authz.unexistent_apikey'] }, 401)
    end

    def validate_restrictions!
      restrictions = Rails.cache.fetch('restrictions', expires_in: 5.minutes) { fetch_restrictions }

      request_ip = @request.remote_ip
      country = Barong::GeoIP.info(ip: request_ip, key: :country)
      continent = Barong::GeoIP.info(ip: request_ip, key: :continent)

      restrict! if restrictions['ip'].include?(request_ip)
      restrict! if restrictions['ip_subnet'].any? { |r| IPAddr.new(r).include?(request_ip) }
      restrict! if restrictions['continent'].any? { |r| r.casecmp?(continent) }
      restrict! if restrictions['country'].any? { |r| r.casecmp?(country) }
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

    def fetch_restrictions
      enabled = Restriction.where(state: 'enabled').to_a

      Restriction::SCOPES.inject(Hash.new) do |table, scope|
        scope_restrictions = enabled.select { |r| r.scope == scope }.map!(&:value)
        table.tap { |t| t[scope] = scope_restrictions }
      end
    end

    def restrict!
      Rails.logger.info("Access denied for #{session[:uid]} because ip #{@request.remote_ip} is resticted")
      error!({ errors: ['authz.access_restricted'] }, 401)
    end

    def validate_permissions!(user)
      # Caches Permission.all result to optimize
      permissions = Rails.cache.fetch('permissions') { Permission.all.to_ary }

      permissions.select! { |a| a.role == user.role && ( a.verb == @request.env['REQUEST_METHOD'] || a.verb == 'ALL' ) && @path.starts_with?(a.path) }
      actions = permissions.blank? ? [] : permissions.pluck(:action).uniq

      if permissions.blank? || actions.include?('DROP') || !actions.include?('ACCEPT')
        log_activity(user.id, 'denied')
        error!({ errors: ['authz.invalid_permission'] }, 401)
      end

      if actions.include?('AUDIT')
        topic = permissions.select { |a| a.action == 'AUDIT' }[0].topic
        log_activity(user.id, 'succeed', topic)
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
        user_ip: @request.remote_ip,
        path: @path,
        topic: topic,
        verb: @request.env['REQUEST_METHOD'],
        payload: @request.params
      }
    end

    # black/white list validation. takes ['block', 'pass'] as a parameter
    def restricted?(type)
      return false if @rules[type].nil? # if no authz rules provided

      @rules[type].each do |t|
        return true if @path.starts_with?(t) # if request path is inside the rules list
      end
      false # default
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

      error!({ errors: ['authz.disabled_2fa'] }, 401) unless user.otp
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
