# frozen_string_literal: true

module Barong
  # Captcha config control module
  class CaptchaPolicy
    include ActiveSupport::Configurable

    class << self
      def define
        yield self
      end

      def set(key, value = false)
        config.transform_values! { false } if value
        config[key] = value
      end
    end
  end
end
