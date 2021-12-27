module Barong
  class SysJWT
    ALGO = 'ES256'
    EXPIRE = 10

    def initialize(jwk: JSON.parse(ENV.fetch('P2P_API_SYS_JWK')))
      @jwk = ::JWT::JWK.import jwk
    end

    # tgid:
    # uid:
    # email:
    # nickname:
    # email_verified:
    # locale:

    def encode(payload)
      ::JWT.encode merge_claims(payload), @jwk.keypair, ALGO
    end

    def merge_claims(payload)
      payload.reverse_merge(
        iat: Time.now.to_i,
        jti: SecureRandom.hex(10),
        aud: 'sys',
        exp: (Time.now + EXPIRE).to_i,
      )
    end
  end
end
