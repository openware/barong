# frozen_string_literal: true

module APIHelpers
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

  def delete_json(destination, body, headers = {})
    delete destination,
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

  def create_label_with_level(user, level, scope: 'private')
    create(:label, user: user,
                   key: level.key,
                   value: level.value,
                   scope: scope)
  end

  def set_level(user, level)
    raise "level doesn't exist" if Level.last.id < level
    levels = Level.where(id: 1..level)
    levels.each do |lvl|
      Label.find_or_create_by(user: user, key: lvl.key, value: lvl.value, scope: 'private')
    end
  end

  def applogic_signed_jwt(payload)
    multisig_jwt(payload, management_api_v2_keychain, :james, management_api_v2_algorithms)
  end

  def multisig_jwt(payload, keychain, signers, algorithms)
    JWT::Multisig.generate_jwt(payload, keychain.slice(*signers), algorithms)
  end

  def multisig_jwt_management_api_v2(payload, *signers)
    multisig_jwt(payload, management_api_v2_keychain, signers, management_api_v2_algorithms)
  end

  def management_api_v2_keychain
    require 'openssl'
    { james:  OpenSSL::PKey::RSA.generate(2048),
      john:   OpenSSL::PKey::RSA.generate(2048),
      david:  OpenSSL::PKey::RSA.generate(2048),
      robert: OpenSSL::PKey::RSA.generate(2048),
      alex:   OpenSSL::PKey::RSA.generate(2048),
      jeff:   OpenSSL::PKey::RSA.generate(2048) }
  end
  memoize :management_api_v2_keychain

  def management_api_v2_algorithms
    management_api_v2_keychain.each_with_object({}) { |(k, _v), memo| memo[k] = 'RS256' }
  end
  memoize :management_api_v2_algorithms

  def management_api_v2_security_configuration
    API::V2::Management::JWTAuthenticationMiddleware.security_configuration
  end

  def defaults_for_management_api_v2_security_configuration!
    config = { jwt: {} }
    config[:keychain] = management_api_v2_keychain.each_with_object({}) do |(signer, key), memo|
      memo[signer] = { algorithm: management_api_v2_algorithms.fetch(signer), value: key.public_key }
    end
    API::V2::Management::JWTAuthenticationMiddleware.security_configuration = config
  end

  def codec
    @_codec ||= Barong::JWT.new(key: Barong::App.config.keystore.private_key)
  end

end

RSpec.configure { |config| config.include APIHelpers }
