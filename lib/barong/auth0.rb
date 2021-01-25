require 'jwt'

module Barong
  class Auth0
    def initialize; end

    def decode_and_verify(id_token)
      claims = ::JWT.decode(id_token, nil, false, algorithm: 'RS256')
      claims[0]
    end

    def logout_uri(client_id, return_uri)
      URI::HTTPS.build(host: Barong::App.config.auth0_tenant_address, path: '/v2/logout', query: {
        client_id: client_id,
        returnTo: return_uri
      }.to_query)
    end
  end
end
