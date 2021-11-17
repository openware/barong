require "base64"
class Barong::BitzlatoSession

  PREFIX = 's'

  P2P_SESSION_REDIS_URL = ENV.fetch('P2P_SESSION_REDIS_URL', 'redis:/127.0.0.1/0')

  attr_reader :session_id, :signature, :secret

  def self.generate_cookie(session_id, secret)
    CGI.escape(
      PREFIX + ':' + session_id + '.' + sign_session_id(session_id, secret)
    )
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

  def session_data
    return @session_data if @session_data

    raise "Cookie is not valid (#{@cookie})" unless valid?
    raw_session_data = redis.get('sess:' + session_id)
    raise "No raw_session_data (#{@cookie}" if raw_session_data.blank?

    @session_data = JSON.parse raw_session_data
  end

  private

  def redis
    @redis = Redis.new(url: P2P_SESSION_REDIS_URL)
  end

  def split_cookie(cookie)
    CGI.unescape(cookie).split(/[:.]/)
  end
end
