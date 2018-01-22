# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def doorkeeper_unauthorized_render_options(error: nil)
    { json: { error: 'Not authorized' } }
  end
end
