# frozen_string_literal: true

module Barong
  class App
    include ActiveSupport::Configurable

    class Error < ::StandardError; end

    class << self
      def define
        yield self
      end

      def set(key, default = nil)
        if env(key)
          config[key] = env(key)

        elsif Rails.application.credentials[key]
          config[key] = Rails.application.credentials[key]

        else
          raise Error, "Config #{key} missing" if default.nil?
          config[key] = default
        end
        validate!(key, config[key])
      end

      def env(key)
        ENV[key.to_s.upcase]
      end

      def validate!(key, value)
        case key
        when :barong_uid_prefix
          raise Error.new('Invalid prefix') \
            unless /^[A-z]{2,6}$/ =~ value
        end
      end

    end
  end
end
