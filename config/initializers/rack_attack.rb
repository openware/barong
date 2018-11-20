class Rack::Attack

  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  phone_rate_limit = ENV.fetch('PHONE_VERIFICATION_RATE_LIMIT', 5)

  # Limit nubmer of calls from ip per second
  throttle('logins/ip',limit: 10, period: 1.seconds) do |req|
    req.ip
  end

  # Limit number of phone verification calls per number
  throttle('phone_verification/number', limit: phone_rate_limit , period: 24.hours) do |req|
    case req.path
    when '/phones/verification'
      req.ip
    when '/api/v1/phones'
      req.ip
    when '/api/v1/phones/send_code'
      req.ip
    end
  end
end
