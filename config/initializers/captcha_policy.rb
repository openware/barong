# frozen_string_literal: true

require 'barong/captcha_policy'

Barong::CaptchaPolicy.define do |config|
  config.set(:disabled, true)
  config.set(:geetest_captcha, false)
  config.set(:re_captcha, false)
end
