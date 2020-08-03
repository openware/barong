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
  # https://github.com/openware/barong/blob/master/docs/configuration.md#general-configuration
  config.set(:app_name, 'Barong')
  config.set(:domain, 'openware.com')
  config.set(:uid_prefix, 'ID', regex: /^[A-z]{2,6}$/)
  config.set(:session_name, '_barong_session')
  config.set(:session_expire_time, '1800', type: :integer)
  config.set(:kyc_provider, 'kycaid', values: %w[kycaid local])
  config.set(:required_docs_expire, 'true', type: :bool)
  config.set(:doc_num_limit, '10', type: :integer)
  config.set(:geoip_lang, 'en', values: %w[en de es fr ja ru])
  config.set(:csrf_protection, 'true', type: :bool)
  config.set(:apikey_nonce_lifetime, '5000', type: :integer)
  config.set(:gateway, 'cloudflare', values: %w[akamai cloudflare])
  config.set(:jwt_expire_time, '3600', type: :integer)
  config.set(:profile_double_verification, 'false', type: :bool)
  
  # Password configuration  -----------------------------------------------
  # https://github.com/openware/barong/blob/master/docs/configuration.md#password-configuration
  config.set(:password_regexp, '^(?=.*[[:lower:]])(?=.*[[:upper:]])(?=.*[[:digit:]])(?=.*[[:graph:]]).{8,80}$', type: :regexp)
  config.set(:password_min_entropy, '14', type: :integer)
  config.set(:password_use_dictionary, 'true', type: :bool)

  # CAPTCHA configuration ---------------------------------------------
  # https://github.com/openware/barong/blob/master/docs/configuration.md#captcha-configuration
  config.set(:captcha, 'none', values: %w[none recaptcha geetest])
  config.set(:geetest_id, '')
  config.set(:geetest_key, '')
  config.set(:recaptcha_site_key, '')
  config.set(:recaptcha_secret_key, '')

  # Dependencies configuration (vault, redis, rabbitmq) ---------------
  # https://github.com/openware/barong/blob/master/docs/configuration.md#dependencies-configuration-vault-redis-rabbitmq
  config.set(:event_api_rabbitmq_host, 'localhost')
  config.set(:event_api_rabbitmq_port, '5672')
  config.set(:event_api_rabbitmq_username, 'guest')
  config.set(:event_api_rabbitmq_password, 'guest')
  config.set(:vault_address, 'http://localhost:8200')
  config.set(:vault_token, 'changeme')
  config.set(:vault_app_name, 'barong')
  config.set(:redis_cluster, 'false', type: :bool)
  config.set(:redis_url, 'redis://localhost:6379/1')
  config.set(:redis_password, '')

  # CORS configuration  -----------------------------------------------
  # https://github.com/openware/barong/blob/master/docs/configuration.md#api-cors-configuration
  config.set(:api_cors_origins, '*')
  config.set(:api_cors_max_age, '3600')
  config.set(:api_cors_allow_credentials, 'false', type: :bool)

  # Config files configuration ----------------------------------------
  # https://github.com/openware/barong/blob/master/docs/configuration.md#config-files-configuration
  config.set(:config, 'config/barong.yml', type: :path)
  config.set(:maxminddb_path, '', type: :path)
  config.set(:seeds_file, Rails.root.join('config', 'seeds.yml'), type: :path)
  config.set(:authz_rules_file, Rails.root.join('config', 'authz_rules.yml'), type: :path)

  # SMTP configuration ------------------------------------------------
  # https://github.com/openware/barong/blob/master/docs/general/env_configuration.md#smtp-configuration
  config.set(:sender_email, 'noreply@barong.io')
  config.set(:sender_name, 'Barong')
  config.set(:smtp_password, '')
  config.set(:smtp_port, 1025)
  config.set(:smtp_host, 'localhost')
  config.set(:smtp_user, '')
  config.set(:default_language, 'en')

  # KYCAID ------------------------------------------------------------
  config.set(:kycaid_authorization_token, '')
  config.set(:kycaid_sandbox_mode, 'true', type: :bool)
  config.set(:kycaid_api_endpoint, 'https://api.kycaid.com/')
end

# KYCAID configuring
KYCAID.configure do |config|
  config.authorization_token = Barong::App.config.kycaid_authorization_token
  config.sandbox_mode = Barong::App.config.kycaid_sandbox_mode
  config.api_endpoint = Barong::App.config.kycaid_api_endpoint
end

ActionMailer::Base.smtp_settings = {
  address: Barong::App.config.smtp_host,
  port: Barong::App.config.smtp_port,
  user_name: Barong::App.config.smtp_user,
  password: Barong::App.config.smtp_password
}

Barong::GeoIP.lang = Barong::App.config.geoip_lang

Rails.application.config.x.keystore = kstore
Barong::App.config.keystore = kstore
