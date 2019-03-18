# frozen_string_literal: true

require_dependency 'barong/event_api'

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.include EventAPI::ActiveRecord::Extension
end

Barong::App.define do |config|
  config.set(:barong_domain, 'changeme.com')
  config.set(:event_api_jwt_private_key)
end
