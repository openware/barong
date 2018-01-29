# frozen_string_literal: true

module ApplicationHelper

  require 'rqrcode'

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

  def generate_qr_code(account)
    url = account.otp_provisioning_uri(account.email, issuer: 'Barong')
    RQRCode::QRCode.new(url).as_html
  end

  def domain_html_tag(text)
    text&.html_safe
  end
end
