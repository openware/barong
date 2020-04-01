# Extend default list of trusted proxies with generic private and cloudflare proxy list

# Cloudflare proxies list
# config/cloudflare_ips.yml fetches every time you build an image. Check Dockerfile l54, l55
cloudflare_ips = File.read('config/cloudflare_ips.yml').split(/\R+/)
extend_proxies = cloudflare_ips.map { |proxy| IPAddr.new(proxy) }

Rails.application.config.action_dispatch.trusted_proxies = ActionDispatch::RemoteIp::TRUSTED_PROXIES + extend_proxies
