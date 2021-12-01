module BitzlatoSession
  def claims
    return if id_token.nil? || id_token.is_a?(Hash) # Были такие ошибочные сессии в редисе
    @claims ||= Barong::Auth0::JWT.verify(id_token).first
  rescue StandardError, JWT::DecodeError => err
    report_exception err, true, id_token: id_token
    nil
  end

  def login! id_token, user_id
    update(
      {
        cookie: {:originalMaxAge=>nil, :expires=>nil, :httpOnly=>true, :domain=>".bitzlato.com", :path=>"/"},
        passport: {
          user: {
            userId: user_id,
            idToken: id_token,
            emailVerified: true,
            # passed2fa: true,
            complete: true,
            # returnReferrer: '',
            # refreshToken: '',
          }
        }
      }.deep_stringify_keys
    )
  end

  def id_token
    fetch('passport').dig('user','idToken') if exists? && key?('passport')
  end
end

class Rack::Session::SessionId
  STORE_PREFIX='sess:'
  def initialize(public_id)
    @public_id = public_id.presence || 's:' + SecureRandom.hex(16).encode!(Encoding::UTF_8) + '.fake'
    @_prefix, @real_session_id, @signature = @public_id.split(/[:.]/)
    Rails.logger.info("Unknown cookie: '#{public_id}'") if @real_session_id.nil?
    @real_session_id ||= SecureRandom.hex(16).encode!(Encoding::UTF_8) + '_fake'
  end

  # Session key for redis-storage
  def private_id
    STORE_PREFIX + @real_session_id
  end
end

class ActionDispatch::Request::Session
  include BitzlatoSession
end

class ActionDispatch::Session::BzRedisStore <  ActionDispatch::Session::RedisStore
  PUBLIC_PREFIX='s'

  SECRET = ENV.fetch('SESSION_SECRET', 'secret')

  def generate_sid
    Rack::Session::SessionId.new generate_cookie SecureRandom.hex(16).encode!(Encoding::UTF_8), SECRET
  end

  private

  def generate_cookie(session_id, secret)
    # CGI.escape value
    PUBLIC_PREFIX + ':' + session_id + '.' + sign_session_id(session_id, secret)
  end

  def sign_session_id(data, secret)
    Base64
      .encode64(OpenSSL::HMAC.digest('SHA256', secret, data))
      .chomp
      .gsub(/\=+$/, '')
  end
end

Rails.application.config.session_store :bz_redis_store,
  expire_after: 14.days,
  key: ENV.fetch('SESSION_KEY', '_barong_session'),
  servers: [ENV.fetch('SESSION_REDIS_URL', ENV.fetch('BARONG_REDIS_URL', 'redis://localhost:6379/1')), serializer: Oj]
