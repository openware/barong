# frozen_string_literal: true

module UserApi
  module V1
    module CORS
      class << self
        def call(headers, origin:)
          headers.reverse_merge!(self.headers(origin))

          # Response may differ if server specifies "*" as allowed origins.
          # See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin
          if headers['Access-Control-Allow-Origin'] != '*'
            headers['Vary'] = [headers['Vary'], 'Origin'].compact.join(', ')
          end

          headers
        end

        def headers(origin)
          whitelisted_origin = ENV.fetch('API_CORS_ORIGINS', '')
                                  .split(',')
                                  .map(&:squish)
                                  .include?(origin)
          allow_insecure = ENV['API_CORS_ALLOW_INSECURE_ORIGINS'].present?
          return build_headers(origin) if whitelisted_origin || allow_insecure

          {}
        end

        private

        def build_headers(origin)
          {
            'Access-Control-Allow-Origin'      => origin,
            'Access-Control-Allow-Methods'     => 'GET, POST, PUT, PATCH, DELETE',
            'Access-Control-Allow-Headers'     => 'Origin, X-Requested-With, Content-Type, Accept, Authorization, Set-Cookie',
            'Access-Control-Allow-Credentials' => ENV['API_CORS_ALLOW_CREDENTIALS'].present?.to_s
          }
        end
      end

      class Middleware < Grape::Middleware::Base
        def call(env)
          request = Grape::Request.new(env)
          origin = request.headers['Origin']
          return [200, CORS.headers(origin), []] if request.options?

          response = @app.call(env)
          headers = response.is_a?(Array) ? response[1] : response.headers
          CORS.call(headers, origin: origin)
          response
        end
      end
    end
  end
end
