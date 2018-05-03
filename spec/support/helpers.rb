# frozen_string_literal: true

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
         params: normalize_body(body),
         headers: headers.reverse_merge('Content-Type' => 'application/json')
  end

  def put_json(destination, body, headers = {})
    put destination,
        params: normalize_body(body),
        headers: headers.reverse_merge('Content-Type' => 'application/json')
  end

  def normalize_body(body)
    body.is_a?(String) ? body : body.to_json
  end

  def create_jwt_token(account)
    secret_key = Rails.application.secrets.secret_key_base

    payload = {
      account_uid: account.uid,
      iat: Time.current.to_i,
      jti: SecureRandom.hex(12).upcase,
      exp: 30.seconds.from_now.to_i,
      sub: 'session',
      iss: 'barong'
    }

    JWT.encode(payload, secret_key, 'HS256')
  end

  def jwt_decode(token)
    JWT.decode(token,
               Rails.application.secrets.secret_key_base,
               true,
               token_verification_options)
  end

  def token_verification_options
    {
      verify_expiration: true,
      verify_iat: true,
      verify_jti: true,
      sub: 'session',
      verify_sub: true,
      algorithms: ['HS256'],
      iss: 'barong',
      verify_iss: true
    }
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

RSpec.configure { |config| config.include APITestHelpers }
