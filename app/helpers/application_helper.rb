# frozen_string_literal: true

module ApplicationHelper
  def domain_stylesheet_tag(url)
    return stylesheet_link_tag(url) unless url.nil?
  end
end
