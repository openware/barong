# frozen_string_literal: true

require_dependency 'barong/authorize'

# Rails Metal base controller to manage AuthZ story
class AuthorizeController < ActionController::Metal
  include AbstractController::Rendering

  # /api/v2/auth endpoint
  def authorize
    @restrictions = Rails.cache.fetch('restrictions', expires_in: 5.minutes) { fetch_restrictions }

    # whitelink path
    unless params[:path] == 'api/v2/barong/identity/users/access'
      Restriction::CATEGORIES.each do |category|
        restriction = first_matched_restriction(category)
        if restriction && category.in?(%w[blacklist maintenance])
          return deny_access(category, restriction)
        elsif restriction && category == 'blocklogin' && params[:path] == 'api/v2/barong/identity/sessions'
          return deny_access(category, restriction)
        elsif restriction && category == 'whitelist'
          break
        end
      end
    end

    req = Barong::Authorize.new(request, params[:path]) # initialize params of request
    # checks if request is blacklisted
    return access_error!('authz.permission_denied', 401) if req.under_path_rules?('block')

    response.status = 200
    return if req.under_path_rules?('pass') # check if request is whitelisted

    response.headers['Authorization'] = req.auth # sets bearer token
  rescue Barong::Authorize::AuthError => e # returns error from validations
    response.body = e.message
    response.status = e.code
  end

  private

  # finds first (if exist) the most precise restriction ip -> ip_subnet -> continent -> country
  def first_matched_restriction(category)
    request_ip = remote_ip
    country = Barong::GeoIP.info(ip: request_ip, key: :country)
    continent = Barong::GeoIP.info(ip: request_ip, key: :continent)
    if restriction = @restrictions[category]['all']&.find { |r| r.present? }                                    then return restriction end
    if restriction = @restrictions[category]['ip']&.find { |r| r.include?(request_ip) }                         then return restriction end
    if restriction = @restrictions[category]['ip_subnet']&.find { |r| IPAddr.new(r[0])&.include?(request_ip) }  then return restriction end
    if restriction = @restrictions[category]['continent']&.find { |r| r[0]&.casecmp?(continent) }               then return restriction end
    if restriction = @restrictions[category]['country']&.find { |r| r[0]&.casecmp?(country) }                   then return restriction end
  end

  # as a result gives complex Hash, { category: { scope: values, scope: values }, category: { scope: values, scope: values } }
  #   { "blacklist"=>{"continent"=>[], "country"=>[], "ip"=>[], "ip_subnet"=>[]},
  #     "whitelist"=>{"continent"=>[], "country"=>[], "ip"=>[], "ip_subnet"=>[]},
  #     "maintenance"=>{"continent"=>[], "country"=>[], "ip"=>[], "ip_subnet"=>[]} }
  def fetch_restrictions
    enabled = Restriction.where(state: 'enabled').to_a

    Restriction::CATEGORIES.inject({}) do |table, category|
      grouped_by_category = enabled.select { |r| r.category == category }

      grouped_by_scope = Restriction::SCOPES.inject({}) do |table, scope|
        scope_restrictions = grouped_by_category.select { |r| r.scope == scope }.pluck(:value, :code)
        table.tap { |t| t[scope] = scope_restrictions }
      end
      table.tap { |t| t[category] = grouped_by_scope }
    end
  end

  def deny_access(category, restriction)
    Rails.logger.info("Access denied for ip #{request.remote_ip} because of #{restriction[0]} restriction")
    access_error!("authz.restrict.#{category}", restriction[1])
  end

  def session
    request.session
  end

  # error for blacklisted routes
  def access_error!(text, code)
    response.status = code
    response.body = { 'errors': [text] }.to_json
  end

  def remote_ip
    # default behaviour, IP from HTTP_X_FORWARDED_FOR
    ip = request.remote_ip

    if Barong::App.config.gateway == 'akamai'
      # custom header that contains only client IP
      true_client_ip = request.env['HTTP_TRUE_CLIENT_IP']
      # take IP from TRUE_CLIENT_IP only if its not nil or empty
      ip = true_client_ip unless true_client_ip.nil? || true_client_ip.empty?
    end

    ip
  end
end
