module Barong
  class JWT

    def initialize(options)
      raise "Missing private key" unless options[:key]
      @options = options.reverse_merge({
        algoritm: 'RS256',
        expire: Barong::App.config.jwt_expire_time,
        sub: 'session',
        iss: 'barong',
        aud: %w[peatio barong]
      })
    end

    def encode(payload)
      ::JWT.encode(merge_claims(payload),
                 @options[:key], @options[:algoritm])
    end

    def decode_and_verify(token, verify_options)
      @verify_options = verify_options.reverse_merge({
        verify_expiration: true,
        verify_not_before: true,
        iss: 'barong',
        verify_iss: true,
        verify_iat: true,
        verify_jti: true,
        aud: %w[peatio barong],
        verify_aud: true,
        sub: 'confirmation',
        verify_sub: true,
        algorithms: 'RS256'
      })
      payload, header = ::JWT.decode(token, @verify_options[:pub_key], true, @verify_options)
      payload.keys.each { |k| payload[k.to_sym] = payload.delete(k) }
      payload
    end

    def merge_claims(payload)
      payload.reverse_merge({
        iat: Time.now.to_i,
        exp: (Time.now + @options[:expire]).to_i,
        sub: @options[:sub],
        iss: @options[:iss],
        aud: @options[:aud],
        jti: SecureRandom.hex(10)
      })
    end
  end
end
