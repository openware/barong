# frozen_string_literal: true

begin
  if Rails.env.production?
    redis_url = ENV.fetch('BARONG_REDIS_URL', 'redis://localhost:6379/1')
    r = Redis.new(url: redis_url)
    r.ping
  end
rescue Redis::CannotConnectError
  Rails.logger.fatal("Error connecting to Redis on #{redis_url} (Errno::ECONNREFUSED)")
  raise 'FATAL: connection to Redis refused'
end
