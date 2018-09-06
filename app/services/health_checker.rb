# frozen_string_literal: true

# Check for services health from Kubernetes
module HealthChecker
  LIVENESS_CHECKS = %i[check_db check_vault].freeze
  READINESS_CHECKS = %i[check_db].freeze

  class << self
    def alive?
      check! LIVENESS_CHECKS
    rescue StandardError => e
      report_exception_to_screen(e)
      false
    end

    def ready?
      check! READINESS_CHECKS
    rescue StandardError => e
      report_exception_to_screen(e)
      false
    end

  private

    def check!(checks)
      checks.all? { |m| send(m) }
    end

    def check_db
      Account.count
      Account.connected?
    end

    def check_vault
      vault_enabled = ENV.fetch('VAULT_ENABLED', false)
      return true unless vault_enabled
      Vault::TOTP.server_available?
    end
  end
end
