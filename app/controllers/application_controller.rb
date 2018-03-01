# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :domain_asset

  def domain_asset(item)
    @website ||= Website.find_by_domain(request.domain)
    @website[item] unless @website.nil? || @website[item].nil?
  end

  def doorkeeper_unauthorized_render_options(error: nil)
    { json: { error: 'Not authorized' } }
  end
end
