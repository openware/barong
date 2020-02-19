# CloudFlare masks the true IP
# This middleware ensures the Rails stack obtains the correct IP when using request.remote_ip
# See https://support.cloudflare.com/hc/en-us/articles/200170786

# class that avoids CloudFlare ip hiding
class CloudFlareMiddleware
  # latest cloudflare IP Ranges https://www.cloudflare.com/ips/
  CLOUDFLARE_IPS = File.read('config/cloudflare_ips.yml').split(/\R+/)
  COMMON_PRIVATE_IPS = ["10.0.0.0/8","172.16.0.0/12","192.168.0.0/16"]
  PROXY_MATCHERS = CLOUDFLARE_IPS + COMMON_PRIVATE_IPS

  attr_reader :proxies

  def initialize(app)
    @app = app

    @proxies = []
    PROXY_MATCHERS.flatten.each do |matcher|
      @proxies << case matcher
                  when Regexp, IPAddr
                    matcher
                  when String
                    IPAddr.new(matcher)
                  else
                    raise ArgumentError, "Expected String, IPAddr or Regexp but found #{matcher.class} #{matcher.inspect}"
                  end
    end
  end

  def call(env)
    @env = env
    ips = ips_from(@env['HTTP_X_FORWARDED_FOR'])
    Rails.logger.debug "Original http_x_forwarded_for: #{ips}"
    
    @env['HTTP_X_FORWARDED_FOR'] = filter_proxies(ips).join(', ')
    Rails.logger.debug "Filtered from private and cloudflare IPs address: #{@env['HTTP_X_FORWARDED_FOR']}"
    
    @app.call(env)
  end

  protected

  def ips_from(header)
    return [] unless header

    # Split the comma-separated list into an array of strings.
    ips = header.strip.split(/[,\s]+/)
    ips.select do |ip|
      # Only return IPs that are valid according to the IPAddr#new method.
      range = IPAddr.new(ip).to_range
      # We want to make sure nobody is sneaking a netmask in.
      range.begin == range.end
    rescue ArgumentError
      nil
    end
  end

  def filter_proxies(ips)
    ips.reject do |ip|
      @proxies.any? { |proxy| proxy == ip }
    end
  end
end
