# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Require the plugins listed in config/plugins.yml.
require_relative 'plugins'

module Barong
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Stop Rails generator from creating unneeded scripts.
    config.generators.assets = false
    config.generators.helper = false
    config.generators.tests  = false
    config.generators.test_framework :rspec
    config.eager_load_paths += %W[#{config.root}/lib]

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*' # Permit CORS from any origin, only in the API route
        resource '/api/*', headers: :any, methods: %i[get post put delete options]
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
