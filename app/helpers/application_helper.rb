# frozen_string_literal: true

module ApplicationHelper

  def domain_stylesheet_tag(url)
    stylesheet_link_tag(url) unless url.nil?
  end

  def domain_logo_tag(url)
    if url.nil?
      image_tag('logo-white.png')
    else
      image_tag(url)
    end
  end

  def domain_html_tag(text)
    text&.html_safe
  end
end
