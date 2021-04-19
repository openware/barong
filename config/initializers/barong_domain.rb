# frozen_string_literal: true

require 'barong/app'

module Barong
  class App
    class << self
      def url
        if Barong::App.config.domain.match? %r{^http(s?)://}
          app_url = Barong::App.config.domain
        else
          schema = Barong::App.config.tls_enabled ? 'https' : 'http'
          app_url = "#{schema}://#{Barong::App.config.domain}"
        end
        app_url
      end
    end
  end
end
