# frozen_string_literal: true

module UserApi
  module V1
    module Middlewares
      class DeviceMiddleware < Grape::Middleware::Base
        extend Memoist

        def before
          env['device_uuid'] = headers['DEVICE_UUID']
          env['device_params'] = {
            ip: remote_ip,
            country: country_by_ip(remote_ip),
            user_agent: request.user_agent,
            browser: request.browser,
            os: request.os
          }
        end

      private

        def remote_ip
          env['action_dispatch.remote_ip'].to_s
        end
        memoize :remote_ip

        def request
          Grape::Request.new(env)
        end
        memoize :request

        def geo_db
          MaxMindDB.new(Rails.root.join('vendor', 'GeoLite2-Country.mmdb'))
        end
        memoize :geo_db

        def country_by_ip(ip_address)
          result = geo_db.lookup(ip_address)
          result.found? ? result.country.name : 'unknown'
        end
        memoize :country_by_ip
      end
    end
  end
end
