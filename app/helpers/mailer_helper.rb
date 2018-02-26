# frozen_string_literal: true

module MailerHelper

  include ApplicationHelper

  def determine_logo_url
    host      = confirmation_url(Account.first) # TODO: need way to determine a host correctly, just tip to me, but it works!
    websites  = Website.all
    logo_url  = nil
    websites.each do |website|
      logo_url = website.logo if host.include?(website.domain)
    end
    domain_logo_tag(logo_url)
  end

end
