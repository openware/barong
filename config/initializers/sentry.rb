if ENV['SENTRY_DSN_BACKEND'].present? && ENV['SENTRY_ENV'].to_s.split(',').include?(Rails.env)
  require 'sentry-raven'
  Raven.configure { |config| config.dsn = ENV['SENTRY_DSN_BACKEND'] }
end
