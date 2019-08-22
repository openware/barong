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
  config.set(:app_name, 'Barong')
  config.set(:barong_domain, 'barong.io')
  config.set(:barong_uid_prefix, 'ID', regex: /^[A-z]{2,6}$/)
end

Rails.application.config.x.keystore = kstore
Barong::App.config.keystore = kstore
