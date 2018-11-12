module Barong
  class JWT

    def initialize(options)
      raise "Missing private key" unless options[:key]
      @options = options.merge({
        algoritm: 'RS256',
        expire: 6000,
        sub: 'session',
        iss: 'barong',
        aud: %w[peatio barong]
      })
    end

    def encode(payload)
      ::JWT.encode(merge_claims(payload),
                 @options[:key], @options[:algoritm])
    end

    def merge_claims(payload)
      payload.merge({
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
