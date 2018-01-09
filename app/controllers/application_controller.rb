class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def index
    render html: 'Hello, world!', layout: true
  end
end
