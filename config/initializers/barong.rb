# frozen_string_literal: true


# 1/ check if ENV key exist then validate and set
# 2/ if no check in credentials then validate and set
# 3/ if no generate display warning, raise error in production, and set

require 'barong/app'
require 'barong/keystore'

begin
  private_key_path = ENV['JWT_PRIVATE_KEY_PATH']

  if !private_key_path.nil?
    pkey = Barong::KeyStore.open!(private_key_path)
    Rails.logger.info('Loading private key from: ' + private_key_path)

  elsif Rails.application.credentials.has?(:private_key)
    pkey = Barong::KeyStore.read!(Rails.application.credentials.private_key)
    Rails.logger.info('Loading private key from credentials.yml.enc')

  elsif !Rails.env.production?
    pkey = Barong::KeyStore.generate
    Rails.logger.warn('Warning !! Generating private key')

  else
    raise Barong::KeyStore::Fatal
  end
rescue Barong::KeyStore::Fatal
  Rails.logger.fatal('Private key is invalid')
  raise 'FATAL: Private key is invalid'
end

kstore = Barong::KeyStore.new(pkey)

Barong::App.define do |config|
  # General configuration ---------------------------------------------
  # https://github.com/openware/barong/blob/master/docs/general/env_configuration.md#general-configuration

  config.set(:app_name, 'Barong')
  config.set(:domain, 'openware.com')
  config.set(:uid_prefix, 'ID', regex: /^[A-z]{2,6}$/)
  config.set(:session_name, '_barong_session')
  config.set(:session_expire_time, '1800', type: :integer)
  config.set(:required_docs_expire, 'true', type: :bool)
  config.set(:doc_num_limit, '10', type: :integer)
  config.set(:geoip_lang, 'en', values: %w[en de es fr ja ru])

  # CAPTCHA configuration ---------------------------------------------
  # https://github.com/openware/barong/blob/master/docs/general/env_configuration.md#captcha-configuration
  config.set(:captcha, 'none', values: %w[none recaptcha geetest])
  config.set(:geetest_id, '')
  config.set(:geetest_key, '')
  config.set(:recaptcha_site_key, '')
  config.set(:recaptcha_secret_key, '')

  # Dependencies configuration (vault, redis, rabbitmq) ---------------
  # https://github.com/openware/barong/blob/master/docs/general/env_configuration.md#dependencies-configuration-vault-redis-rabbitmq
  config.set(:event_api_rabbitmq_host, 'localhost')
  config.set(:event_api_rabbitmq_port, '5672')
  config.set(:event_api_rabbitmq_username, 'guest')
  config.set(:event_api_rabbitmq_password, 'guest')
  config.set(:vault_address, 'http://localhost:8200')
  config.set(:vault_token, 'changeme')

  # CORS configuration  -----------------------------------------------
  config.set(:api_cors_origins, '*')
  config.set(:api_cors_max_age, '3600')
  config.set(:api_cors_allow_credentials, 'false', type: :bool)

  # Config files configuration ----------------------------------------
  # https://github.com/openware/barong/blob/master/docs/general/env_configuration.md#config-files-configuration
  config.set(:config, 'config/barong.yml', type: :path)
  config.set(:maxminddb_path, '', type: :path)
  config.set(:seeds_file, Rails.root.join('config', 'seeds.yml'), type: :path)
  config.set(:authz_rules_file, Rails.root.join('config', 'authz_rules.yml'), type: :path)
end

Barong::GeoIP.lang = Barong::App.config.geoip_lang

Rails.application.config.x.keystore = kstore
Barong::App.config.keystore = kstore
