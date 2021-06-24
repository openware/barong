# frozen_string_literal: true

Sentry.init do |config|
  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 1
  # or
  config.traces_sampler = lambda do |_context|
    true
  end

  config.send_default_pii = true
  config.enabled_environments = %w[production staging]
end
