# frozen_string_literal: true

module UserApi
  module V1
    module CORS
      class << self
        def call(headers)
          headers.reverse_merge!(self.headers)

          # Response may differ if server specifies "*" as allowed origins.
          # See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin
          if headers['Access-Control-Allow-Origin'] != '*'
            headers['Vary'] = [headers['Vary'], 'Origin'].compact.join(', ')
          end

          headers
        end

        def headers
          {
            'Access-Control-Allow-Origin'      => ENV.fetch('API_CORS_ORIGINS', '*'),
            'Access-Control-Allow-Methods'     => 'GET, POST, PUT, PATCH, DELETE',
            'Access-Control-Allow-Headers'     => 'Origin, X-Requested-With, Content-Type, Accept, Authorization',
            'Access-Control-Allow-Credentials' => ENV['API_CORS_ALLOW_CREDENTIALS'].present?.to_s
          }
        end
      end

      class Middleware < Grape::Middleware::Base
        def call(env)
          request = Grape::Request.new(env)
          if request.options?
            [200, CORS.headers, []]
          else
            response = @app.call(env)
            headers = response.is_a?(Array) ? response[1] : response.headers
            CORS.call(headers)
            response
          end
        end
      end
    end
  end
end
