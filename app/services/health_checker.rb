# frozen_string_literal: true

module Services
  module HealthChecker
    LIVENESS_CHECKS = %i[check_db check_redis check_rabbitmq].freeze
    READINESS_CHECKS = %i[check_db].freeze

    class << self
      def alive?
        check! LIVENESS_CHECKS
      rescue StandardError => e
        Rails.logger.error "#{e.message}\n#{e.backtrace[0..5].join("\n")}"
        false
      end

      def ready?
        check! READINESS_CHECKS
      rescue StandardError => e
        Rails.logger.error "#{e.message}\n#{e.backtrace[0..5].join("\n")}"
        false
      end

      private

      def check!(checks)
        checks.all? { |m| send(m) }
      end

      def check_db
        Permission.count
        ActiveRecord::Base.connected?
      end

      def check_redis
        Rails.cache.redis.ping == 'PONG'
      end

      def check_rabbitmq
        Bunny.run(rabbitmq_credentials) { |c| c.connected? }
      end

      def rabbitmq_credentials
        if Barong::App.config.event_api_rabbitmq_url.present?
          Barong::App.config.event_api_rabbitmq_url
        else
          {
            host: Barong::App.config.event_api_rabbitmq_host,
            port: Barong::App.config.event_api_rabbitmq_port,
            username: Barong::App.config.event_api_rabbitmq_username,
            password: Barong::App.config.event_api_rabbitmq_password
          }
        end
      end
    end
  end
end
