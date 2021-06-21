SecureHeaders::Configuration.default do |config|
  config.cookies = {
    samesite: {
      none: true # mark all cookies as SameSite=lax
    }
  }
end if defined? SecureHeaders
