source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.0'

gem 'api-pagination', '~> 4.8.2'

gem 'env-tweaks', '~> 1.0.0'
gem 'omniauth-google-oauth2'
gem 'omniauth-auth0', '~> 2.0.0'

gem 'fog-google',  '~> 0.1.0'
gem 'fog-aws',     '~> 2.0.1'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.1'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.4.4', '< 0.6.0'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'mini_racer', platforms: :ruby

gem 'kaminari'

gem 'peatio', '~> 0.4.4'
gem 'rack-cors', '~> 1.0.2'

# REST-like API framework for Ruby
gem 'grape',        '~> 1.0'
gem 'grape-entity', '~> 0.7.1'
gem 'grape-swagger', '~> 0.28'
gem 'grape-swagger-entity', '~> 0.2'
gem 'grape_logging', '~> 1.8.0'
gem 'memoist', '~> 0.16'
gem 'jwt', '~> 2.1'
gem 'jwt-multisig', '~> 1.0'
gem 'bunny'
gem 'phonelib',     '~> 0.6.0'
gem 'twilio-ruby',  '~> 5.6.0'
gem 'vault',        '~> 0.1'
gem 'redis-rails', '~> 5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'

gem 'bcrypt', '~> 3.1'
gem 'email_validator', require: 'email_validator/strict'
gem 'countries', require: 'countries/global'
gem 'browser', require: "browser/browser"
gem 'carrierwave', '~> 1.2.2'
gem 'bump'

# Use gem to verify recatpcha on server side
gem 'recaptcha'
# Password validators
gem 'strong_password', '~> 0.0.6'
# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' or 'binding.pry' anywhere in the code to stop execution and get a debugger console
  gem 'pry-byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails',  '~> 4.11'
  gem 'faker',              '~> 1.8'
end

group :development do
  gem 'grape_on_rails_routes', '~> 0.3.2'
  gem 'web-console',  '>= 3.3.0'
  gem 'listen',       '>= 3.0.5', '< 3.2'
  gem 'annotate',     '~> 2.7'
  gem 'spring'
  gem 'pry-rails'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  # gem 'selenium-webdriver'
  # gem 'chromedriver-helper'
  gem 'rspec-rails',         '~> 3.8'
  gem 'shoulda-matchers',    '~> 4.0.0.rc1'
  gem 'rails-controller-testing'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
