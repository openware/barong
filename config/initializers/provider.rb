# frozen_string_literal: true

require 'barong/provider_policy'

Barong::ProviderPolicy.define do |config|
  config.set(:provider, 'auth0')
end
