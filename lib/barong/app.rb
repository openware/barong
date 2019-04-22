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
        if by_env(key)
          config[key] = by_env(key)

        elsif Rails.application.credentials[key]
          config[key] = Rails.application.credentials[key]

        else
          raise Error, "Config #{key} missing" if default.nil?
          config[key] = default

        end
      end

      def by_env(key)
        ENV[key.to_s.upcase]
      end

    end
  end
end