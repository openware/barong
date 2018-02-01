# frozen_string_literal: true

require 'rqrcode'
require 'rotp'

#
# ApplicationHelper
#
module ApplicationHelper
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

  def generate_qr_code
    account = current_account
    totp = ROTP::TOTP.new(account.seed, issuer: 'Barong')
    url = totp.provisioning_uri(account.email)
    RQRCode::QRCode.new(url, size: 5, level: :l).as_html
  end

  def domain_html_tag(text)
    text&.html_safe
  end
end
