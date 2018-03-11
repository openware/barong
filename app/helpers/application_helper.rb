# frozen_string_literal: true

#
# ApplicationHelper
#
module ApplicationHelper
  def domain_stylesheet_tag(url)
    stylesheet_link_tag(url) unless url.nil?
  end

  def domain_logo_tag(url)
    if url.blank?
      image_tag('logo.png')
    else
      image_tag(url)
    end
  end

  def domain_title(title)
    if title.blank?
      'Lex Exchange - More than just Bitcoin'
    else
      title
    end
  end

  def generate_qr_code
    url = current_account.create_otp.data[:url]
    RQRCode::QRCode.new(url, size: 8, level: :l).as_html
  rescue StandardError => e
    e.message
  end

  def domain_html_tag(text)
    text&.html_safe
  end
end
