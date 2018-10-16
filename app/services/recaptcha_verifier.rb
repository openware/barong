# frozen_string_literal: true

require 'recaptcha/verify'

# Verify recaptcha
class RecaptchaVerifier
  include Recaptcha::Verify

  attr_reader :request

  def initialize(request:)
    @request = request
  end
end
