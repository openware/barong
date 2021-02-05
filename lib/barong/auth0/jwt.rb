# frozen_string_literal: true

module Barong
  module Auth0
    class JWT
      def self.verify(token)
        ::JWT.decode(token,
                     nil,
                     true,       # Verify the signature of this token
                     algorithms: 'RS256',
                     iss:        "https://#{Barong::App.config.auth0_domain}/",
                     verify_iss: true,
                     aud:        Barong::App.config.auth0_client_id,
                     verify_aud: true
        ) do |header|
          jwks_hash[header['kid']]
        end
      end

      def self.jwks_hash
        uri = "https://#{Barong::App.config.auth0_domain}/.well-known/jwks.json"
        jwks_raw = Net::HTTP.get URI(uri)
        jwks_keys = Array(JSON.parse(jwks_raw)['keys'])
        Hash[jwks_keys.map do |k|
          [
            k['kid'],
            OpenSSL::X509::Certificate.new(Base64.decode64(k['x5c'].first)).public_key
          ]
          end
        ]
      end
    end
  end
end
