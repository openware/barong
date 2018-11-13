Barong::App.define do |config|
  config.set(:vault_adress, '')
  config.set(:vault_token, '')
end

Vault.configure do |config|
  config.address = Barong::App.config.vault_adress
  config.token = Barong::App.config.vault_token
  config.ssl_verify = false
  config.timeout = 60
end
