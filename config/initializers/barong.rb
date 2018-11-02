# frozen_string_literal: true

OpenSSL::PKey.read(Rails.application.credentials.private_key).tap do |key|
  raise 'Invalid private key, verify credentials.yml.enc' unless key.private?
  Rails.application.config.x.key.public = key.public_key
end
