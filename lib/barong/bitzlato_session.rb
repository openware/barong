require "base64"
class Barong::BitzlatoSession
  PREFIX = 's'
  ESCAPE_DATA = false
  P2P_SESSION_REDIS_URL = ENV.fetch('P2P_SESSION_REDIS_URL', 'redis:/127.0.0.1/0')

  attr_reader :session_id, :signature, :secret

  def self.generate_cookie(session_id, secret)
    value = PREFIX + ':' + session_id + '.' + sign_session_id(session_id, secret)
    return value unless ESCAPE_DATA
    CGI.escape value
  end

  def self.sign_session_id(data, secret)
    Base64
      .encode64(OpenSSL::HMAC.digest("SHA256", secret, data))
      .chomp
      .gsub(/\=+$/, '')
  end

  def initialize(secret: ENV.fetch('P2P_SESSION_SECRET'), cookie: )
    @secret = secret
    @cookie = cookie
    @_prefix, @session_id, @signature = split_cookie cookie
  end

  def valid?
    @_prefix == PREFIX &&
      @session_id.is_a?(String) &&
      @signature.is_a?(String) &&
      self.class.sign_session_id(@session_id, secret) == @signature
  end

  # TODO проверить подпись jwt токена
  #
  def user_id
    session_data.dig('passport','user','userId')
  end

  def id_token
    session_data.dig('passport','user','idToken')
  end

  def present?
    raw_session_data.present? && id_token.present? && user_id.present?
  end

  def raw_session_data
    redis.get('sess:' + session_id)
  end

  def raw_session_data=(value)
    raise 'must be a String' unless value.is_a? String

    redis.set('sess:' + session_id, value)
  end

  def logout!
    return unless present?

    self.session_data = session_data.merge('password' => {})
  end

  def claims
    @claims ||= Barong::Auth0::JWT.verify(id_token).first
  end

  def session_data=(value)
    raise 'must be a Hash' unless value.is_a? Hash
    self.raw_session_data = value.to_json
    @session_data = value
  end

  def session_data
    return @session_data if @session_data

    raise "Cookie is not valid (#{@cookie})" unless valid?
    raise "No raw_session_data (#{@cookie}" if raw_session_data.blank?

    @session_data = JSON.parse raw_session_data
  end

  private

  def redis
    @redis = Redis.new(url: P2P_SESSION_REDIS_URL)
  end

  def split_cookie(cookie)
    cookie = CGI.unescape(cookie) if ESCAPE_DATA
    cookie.split(/[:.]/)
  end
end
