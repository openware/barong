# frozen_string_literal: true

if defined?(Sentry)
  Sentry.init do |config|
    config.breadcrumbs_logger = %i[active_support_logger http_logger]
    config.traces_sample_rate = 0.01
    config.send_default_pii = true
    config.enabled_environments = %w[production staging]
  end
end
