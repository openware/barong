# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :domain_stylesheet

  def domain_stylesheet
    return unless  @stylesheet_url.nil?
    website = Website.find_by_domain(request.domain)
    @stylesheet_url = website.nil? || website.stylesheet.empty? ? nil : website.stylesheet
  end

  def doorkeeper_unauthorized_render_options(error: nil)
    { json: { error: 'Not authorized' } }
  end
end
