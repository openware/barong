# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :domain_stylesheet

  def domain_stylesheet
    if @stylesheet_url.nil?
      website = Website.find_by_domain(request.domain)
      unless website.nil? || website.stylesheet.empty?
        @stylesheet_url = website.stylesheet
      end
    end
    return @stylesheet_url
  end

  def doorkeeper_unauthorized_render_options(error: nil)
    { json: { error: 'Not authorized' } }
  end
end
