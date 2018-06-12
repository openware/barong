# frozen_string_literal: true

#
# ApplicationHelper
#
module ApplicationHelper
  def domain_title_tag(text)
    if text.blank?
      'Barong'
    else
      text
    end
  end

  def domain_stylesheet_tag(url)
    stylesheet_link_tag(url) unless url.nil?
  end

  def domain_logo_tag(url)
    if url.blank?
      image_tag('logo-white.png')
    else
      image_tag(url)
    end
  end

  def domain_favicon_tag
    url = domain_asset :favicon

    if url.blank?
      return favicon_link_tag asset_path('favicon.png'), rel: 'icon', type:  'image/png'
    end

    content_tag :link, nil, rel: 'icon', href: url
  end

  def domain_html_tag(text)
    text&.html_safe
  end

  def show_level_mapping
    Level.all.map do |lvl|
      "#{lvl.key}:#{lvl.value} scope \"private\"=> account level #{lvl.id}"
    end.join("\n")
  end
end
