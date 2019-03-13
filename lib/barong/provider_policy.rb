# frozen_string_literal: true

module Barong
  # Provider config control module
  class ProviderPolicy
    include ActiveSupport::Configurable

    class << self
      def define
        yield self
      end

      def set(key, value)
        config[key] = value
        config[key] = 'native' unless %w[auth0 google_oauth2].include?(value)
      end
    end
  end
end
