Barong::App.define do |config|
  config.set(:api_cors_origins, '*')
  config.set(:api_cors_max_age, '3600')
  config.set(:api_cors_allow_credentials, 'false')
end
