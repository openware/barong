# frozen_string_literal: true

module MailerHelper

  def determine_logo_url
    host      = confirmation_url(Account.first) # TODO: need way to determine a host correctly, just tip to me, but it works!
    websites  = Website.all
    logo_url  = nil
    websites.each do |website|
      logo_url = website.logo if host.include?(website.domain)
    end

    if logo_url.blank?
      image_tag('logo-black.png')
    else
      image_tag(logo_url)
    end
  end

end
