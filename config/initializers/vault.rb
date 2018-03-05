require 'vault/totp'

Vault.configure do |config|
  config.address = Rails.application.secrets.vault_adress
  config.token = Rails.application.secrets.vault_token
  config.ssl_verify = false
  config.timeout = 60
end
