# frozen_string_literal: true

require 'vault/rails'

Vault.configure do |config|
  config.enabled = Rails.env.production?
  config.address = Barong::App.config.vault_address
  config.token = Barong::App.config.vault_token
  config.ssl_verify = false
  config.timeout = 60
  config.application = Barong::App.config.vault_app_name
end

if Rails.env.production?
  def renew_process
    token = Vault.auth_token.lookup(Vault.token)
    sleep(token.data[:ttl] * (1 + rand) * 0.1)
    Vault.auth_token.renew(token.data[:id])
  end

  Thread.new do
    loop do
      renew_process
    rescue StandardError => e
      report_exception(e)
      sleep 60
    end
  end
end
