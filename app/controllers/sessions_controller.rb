# oauth session controller
class SessionsController < ApplicationController
  include AbstractController::Rendering
  use ActionDispatch::Session::CookieStore

  def create
    # user = User.last
    user = User.find_or_create_from_auth_hash(auth_hash)
    session[:uid] = user.uid
    response.status = 200
    binding.pry
    response.body = {'maksim': 'pidor'}
  end

  protected

  def session
    request.session_options[:expire_after] = Barong::App.config.session_expire_time.to_i.seconds
    request.session
  end

  def codec
    @_codec ||= Barong::JWT.new(key: Barong::App.config.keystore.private_key)
  end

  def auth_hash
    request.env['omniauth.auth']
  end
end
