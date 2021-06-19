SecureHeaders::Configuration.default do |config|
  config.cookies = {
    samesite: {
      none: true
    }
  }
end if defined? SecureHeaders
