# frozen_string_literal: true

require_dependency 'barong/authorize'

# Rails Metal base controller to manage AuthZ story
class AuthorizeController < ActionController::Metal
  include AbstractController::Rendering
  use ActionDispatch::Session::CookieStore

  # /api/v2/auth endpoint
  def authorize
    req = Barong::Authorize.new(request, params[:path]) # initialize params of request
    # checks if request is blacklisted
    return access_error!('authz.permission_denied', 401) if req.restricted?('block')

    response.status = 200
    return if req.restricted?('pass') # check if request is whitelisted

    request.session_options[:expire_after] = Barong::App.config.session_expire_time.to_i.seconds

    response.headers['Authorization'] = req.auth # sets bearer token
  rescue Barong::Authorize::AuthError => e # returns error from validations
    response.body = e.message
    response.status = e.code
  end

  private

  def session
    request.session
  end

  # error for blacklisted routes
  def access_error!(text, code)
    response.status = code
    response.body = { 'errors': [text] }.to_json
  end
end
