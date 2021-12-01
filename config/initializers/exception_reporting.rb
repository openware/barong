def catch_and_report_exception(options = {})
  begin
    yield
    nil
  rescue options.fetch(:class) { StandardError } => e
    report_exception(e)
    e
  end
end

def report_exception(exception, report_to_ets = true, meta = {})
  report_exception_to_screen(exception)
  report_exception_to_ets(exception, meta) if report_to_ets
end

def report_exception_to_screen(exception)
  Rails.logger.unknown exception.inspect
  Rails.logger.unknown Array(exception.backtrace).join("\n") if exception.respond_to?(:backtrace)
end

def report_exception_to_ets(exception, meta = {})
  if defined?(Bugsnag)
    Bugsnag.notify exception do |b|
      b.meta_data = meta
    end
  end
  Sentry.capture_exception(exception) if defined?(Sentry)
rescue => ets_exception
  report_exception(ets_exception, false)
end
