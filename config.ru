# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
require 'rack/cors'
# Load CORS::Validations module
require_relative 'lib/barong/cors/validations'

use Rack::Cors do
  allow do
    origins Barong::CORS::Validations.validate_origins(Barong::App.config.api_cors_origins)
    resource '/api/*',
      methods: %i[get post delete put patch options head],
      headers: :any,
      credentials: Barong::App.config.api_cors_allow_credentials,
      max_age: Barong::CORS::Validations.validate_max_age(Barong::App.config.api_cors_max_age)
  end
end

run Rails.application
