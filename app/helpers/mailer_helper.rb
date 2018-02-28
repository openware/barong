# frozen_string_literal: true

module MailerHelper

  def app_name
    ENV.fetch('APP_NAME', 'Barong')
  end

  def url_host
    ENV.fetch('URL_HOST', 'http://localhost:3000')
  end

  def determine_logo_url
    websites  = Website.all
    logo_url  = nil

    websites.each do |website|
      logo_url = website.logo if url_host.include?(website.domain) && website.domain.present?
    end

    if logo_url.blank?
      image_tag('logo-black.png')
    else
      image_tag(logo_url)
    end
  end

end
