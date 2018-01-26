# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ApplicationHelper
  protect_from_forgery with: :exception
  before_action do
    ApplicationHelper::DOMAIN = request.domain
    p inject_css
  end

  def doorkeeper_unauthorized_render_options(error: nil)
    { json: { error: 'Not authorized' } }
  end
end
