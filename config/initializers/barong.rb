# frozen_string_literal: true

OpenSSL::PKey.read(Rails.application.credentials.private_key).tap do |key|
  raise 'The key in rails creds config is not a private key' unless key.private?

  Rails.application.config.x.key.private = key
  Rails.application.config.x.key.public = key.public_key
end
