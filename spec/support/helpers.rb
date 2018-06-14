# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module APITestHelpers
  extend Memoist

  def json_body
    JSON.parse(response.body, symbolize_names: true)
  end

  def expect_status_to_eq(status)
    expect_status.to eq status
  end

  def expect_status
    expect(response.status)
  end

  def expect_body
    expect(json_body)
  end

  def post_json(destination, body, headers = {})
    post destination,
         params: build_body(body),
         headers: headers.reverse_merge('Content-Type' => 'application/json')
  end

  def put_json(destination, body, headers = {})
    put destination,
        params: build_body(body),
        headers: headers.reverse_merge('Content-Type' => 'application/json')
  end

  def build_body(body)
    body.is_a?(String) ? body : body.to_json
  end

  def jwt_keypair_encoded
    require 'openssl'
    require 'base64'
    result = OpenSSL::PKey::RSA.generate(2048).yield_self do |p|
      {
        public:  Base64.urlsafe_encode64(p.public_key.to_pem),
        private: Base64.urlsafe_encode64(p.to_pem)
      }
    end

    ENV['JWT_PUBLIC_KEY'] = result[:public]
    result
  end
  memoize :jwt_keypair_encoded

  def build_ssl_pkey(key)
    OpenSSL::PKey.read(Base64.urlsafe_decode64(key))
  end

  def jwt_encode(payload)
    build_ssl_pkey(jwt_keypair_encoded[:private]).yield_self do |key|
      JWT.encode(payload, key, 'RS256')
    end
  end

  def jwt_decode(token)
    build_ssl_pkey(jwt_keypair_encoded[:public]).yield_self do |key|
      JWT.decode(token, key, true, algorithm: 'RS256')
    end
  end

  def encode_api_key_payload(data)
    jwt_encode data.reverse_merge(iat: Time.current.to_i,
                                  exp: 30.seconds.from_now.to_i,
                                  sub: 'api_key_jwt',
                                  iss: 'external',
                                  jti: SecureRandom.hex(12).upcase)
  end

  def applogic_signed_jwt(payload)
    multisig_jwt(payload, management_api_v1_keychain, :james, management_api_v1_algorithms)
  end

  def multisig_jwt(payload, keychain, signers, algorithms)
    JWT::Multisig.generate_jwt(payload, keychain.slice(*signers), algorithms)
  end

  def multisig_jwt_management_api_v1(payload, *signers)
    multisig_jwt(payload, management_api_v1_keychain, signers, management_api_v1_algorithms)
  end

  def management_api_v1_keychain
    require 'openssl'
    { james:  OpenSSL::PKey::RSA.generate(2048),
      john:   OpenSSL::PKey::RSA.generate(2048),
      david:  OpenSSL::PKey::RSA.generate(2048),
      robert: OpenSSL::PKey::RSA.generate(2048),
      alex:   OpenSSL::PKey::RSA.generate(2048),
      jeff:   OpenSSL::PKey::RSA.generate(2048) }
  end
  memoize :management_api_v1_keychain

  def management_api_v1_algorithms
    management_api_v1_keychain.each_with_object({}) { |(k, _v), memo| memo[k] = 'RS256' }
  end
  memoize :management_api_v1_algorithms

  def management_api_v1_security_configuration
    ManagementAPI::V1::JWTAuthenticationMiddleware.security_configuration
  end

  def defaults_for_management_api_v1_security_configuration!
    config = { jwt: {} }
    config[:keychain] = management_api_v1_keychain.each_with_object({}) do |(signer, key), memo|
      memo[signer] = { algorithm: management_api_v1_algorithms.fetch(signer), value: key.public_key }
    end

    ManagementAPI::V1::JWTAuthenticationMiddleware.security_configuration = config
  end

  def create_label_with_level(account, level, scope: 'private')
    create(:label, account: account,
                   key: level.key,
                   value: level.value,
                   scope: scope)
  end

  def set_level(account, level)
    raise "level doesn't exist" if Level.last.id < level
    levels = Level.where(id: 1..level)
    levels.each do |lvl|
      Label.find_or_create_by(account: account, key: lvl.key, value: lvl.value, scope: 'private')
    end
  end
end
# rubocop:enable Metrics/ModuleLength

RSpec.configure { |config| config.include APITestHelpers }
