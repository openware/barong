# frozen_string_literal: true

module MailerHelper

  def app_name
    ENV.fetch('APP_NAME', 'Barong')
  end

  def determine_logo_url
    domain = headers['Domain-Name'].to_s

    website = Website.find_by(domain: domain)

    if website.blank?
      image_tag('logo-black.png')
    else
      image_tag(website.logo)
    end
  end

end
