# frozen_string_literal: true

module MailerHelper

  def app_name
    ENV.fetch('APP_NAME', 'Barong')
  end

  def url_host
    ENV.fetch('URL_HOST', 'http://localhost:3000')
  end

  def determine_logo_url
    website = Website.find_by(domain: url_host)

    if website.blank?
      image_tag('logo-black.png')
    else
      image_tag(website.logo)
    end
  end

end
