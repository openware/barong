# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Barong
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Adding Grape API
    # Eager loading all app/ folder
    config.eager_load_paths += Dir[Rails.root.join('app')]
    config.eager_load_paths += Dir[Rails.root.join('lib/barong')]

    # custom middleware to ensure the Rails stack obtains the correct IP when using request.remote_ip
    # middleware should be placed right before ActionDispatch::RemoteIp middleware
    # this way use ActionDispatch::ShowExceptions and ActionDispatch::DebugExceptions 
    # can catch the app route exceptions before before the request is handled by middleware.
    # more about ActionDispatch::RemoteIp http://api.rubyonrails.org/classes/ActionDispatch/RemoteIp.html
    require "#{Rails.root}/lib/barong/cloudflare_middleware"
    config.middleware.insert_before(ActionDispatch::RemoteIp, CloudFlareMiddleware)

    # Setup the logger
    config.logger = Logger.new(STDOUT)

    # Load lib folder files to be visible in specs
    config.paths.add 'lib', eager_load: false, autoload: true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
