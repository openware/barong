# frozen_string_literal: true

require 'digest'
require 'net/http'

module CaptchaService
  # Google recaptcha verifier
  class RecaptchaVerifier
    include Recaptcha::Adapters::ControllerMethods

    attr_reader :request

    def initialize(request:)
      @request = request
    end

    def response_valid?(skip_remote_ip:, response:)
      # according to changes in v2 support https://github.com/ambethia/recaptcha#recaptcha-v2-api-and-usage
      # method comes from Recaptcha::Adapters::ControllerMethods
      # https://github.com/ambethia/recaptcha/blob/master/lib/recaptcha/adapters/controller_methods.rb#L10
      verify_recaptcha(secret_key: Barong::App.config.recaptcha_secret_key,
                       model: User,
                       skip_remote_ip: skip_remote_ip,
                       response: response)
    end
  end

  # Geetest.com captcha verifier
  class GeetestVerifier
    def initialize
      @api = 'http://api.geetest.com'
      @validate_path = '/validate.php'
      @register_path = '/register.php'
      @geetest_id = Barong::App.config.geetest_id
      @geetest_key = Barong::App.config.geetest_key
    end

    def validate(response)
      md5 = Digest::MD5.hexdigest(@geetest_key + 'geetest' + response['geetest_challenge'])
      if response['geetest_validate'] == md5
        back = begin
                 post(@api + @validate_path, seccode: response['geetest_seccode'])
               rescue StandardError
                 ''
               end
        return back == Digest::MD5.hexdigest(response['geetest_seccode'])
      end
      false
    end

    def register
      challenge = get(@api + @register_path + "?gt=#{@geetest_id}")
      { gt: @geetest_id, challenge: Digest::MD5.hexdigest(challenge + @geetest_key) }
    rescue StandardError
      ''
    end

    def get(uri)
      Net::HTTP.get_response(URI(uri)).body
    end

    def post(uri, data)
      Net::HTTP.post_form(URI(uri), data).body
    end
  end
end
