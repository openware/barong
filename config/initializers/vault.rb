Barong::App.define do |config|
  config.set(:vault_address, ENV.fetch('BARONG_VAULT_ADDR', 'http://localhost:8200'))
  config.set(:vault_token, ENV.fetch('BARONG_VAULT_TOKEN', 'changeme'))
end

Vault.configure do |config|
  config.address = Barong::App.config.vault_address
  config.token = Barong::App.config.vault_token
  config.ssl_verify = false
  config.timeout = 60
end
