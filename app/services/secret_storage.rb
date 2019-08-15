# frozen_string_literal: true

module SecretStorage
  Error = Class.new(StandardError)

  class <<self

    def server_available?
      read_data('sys/health').present?
    rescue StandardError
      false
    end

    def store_secret(secret, kid)
      write!(secret_path(kid), secret) unless exist?(kid)
    end

    def get_secret(kid)
      read(secret_path(kid)) if exist?(kid)
    end

    def exist?(kid)
      read(secret_path(kid)).present?
    end

   private

    def secret_path(kid)
      "secret/barong/api_key/#{kid}"
    end

    def with_human_error
      yield
    rescue Vault::VaultError => error
      Rails.logger.error { error }
      raise Error, error.message
    end

    def read(key)
      with_human_error do
        Vault.logical.read(key)
      end
    end

    def write!(key, params)
      with_human_error do
        Vault.logical.write(key, value: params)
      end
    end

    def delete!(key)
      with_human_error do
        Vault.logical.delete(key)
      end
    end
  end
end
