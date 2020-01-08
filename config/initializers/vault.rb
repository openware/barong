# frozen_string_literal: true

Vault.configure do |config|
  config.address = Barong::App.config.vault_address
  config.token = Barong::App.config.vault_token
  config.ssl_verify = false
  config.timeout = 60
end
