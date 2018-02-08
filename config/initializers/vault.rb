if Rails.env.production?
  Vault.configure do |config|
    config.address = Rails.application.secrets.vault_adress ENV["VAULT_ADDR"]
    config.token = Rails.application.secrets.vault_token ENV["VAULT_TOKEN"]
    config.ssl_verify = false
    config.timeout = 60
  end
end