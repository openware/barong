Rails.application.configure do
  # Using cache for sessions and permissions forces to use redis cache_store as mandatory store
  # Here we use ENV.fetch instead of Barong::App.config, because environment/* files loads before lib and initializers
  if ENV.true?('BARONG_REDIS_CLUSTER')
    config.cache_store = :redis_cache_store, { driver: :hiredis, cluster: [ENV.fetch('BARONG_REDIS_URL')], password: ENV.fetch('BARONG_REDIS_PASSWORD') }
  else
    config.cache_store = :redis_cache_store, { driver: :hiredis, url: ENV.fetch('BARONG_REDIS_URL', 'redis://localhost:6379/1') }
  end
end
