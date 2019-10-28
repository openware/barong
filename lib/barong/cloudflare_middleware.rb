# CloudFlare masks the true IP
# This middleware ensures the Rails stack obtains the correct IP when using request.remote_ip
# See https://support.cloudflare.com/hc/en-us/articles/200170786

# class that avoids CloudFlare ip hiding
class CloudFlareMiddleware
  # latest cloudflare IP Ranges https://www.cloudflare.com/ips/
  PROXY_MATCHERS = File.read('config/cloudflare_ips.yml').split(/\R+/)

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
    ips = ips_from('HTTP_X_FORWARDED_FOR')
    @env['HTTP_X_FORWARDED_FOR'] = filter_proxies(ips).join(', ')

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
