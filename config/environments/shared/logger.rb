# encoding: UTF-8
# frozen_string_literal: true

Rails.application.configure do
  # Available levels (verbosity goes from high to less): debug, info, warn, error, fatal.
  # Default level for production is warn, otherwise – debug.
  log_level = ENV.fetch('LOG_LEVEL', Rails.env.production? ? :warn : :debug)
  config.log_formatter = Rails.env.production? || Rails.env.staging? ? JSONLogFormatter.new : Logger::Formatter.new

  # Prepend all log lines with the following tags.
  config.log_tags = [ :host, :remote_ip, :request_id ] if Rails.env.production? || Rails.env.staging?

  # In non-test environments logging always goes to STDOUT since this is the most appropriate way
  # to get logs in Docker environment.
  unless Rails.env.test?
    logger = ActiveSupport::Logger.new STDERR, level: log_level
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  ActiveRecord::Base.logger = nil unless Rails.env.developmen? || Rails.env.test?

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = log_level
end
