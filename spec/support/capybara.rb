# frozen_string_literal: true

screen_size = [1280, 800]

if Barong.config['selenium_host'].present?
  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new \
      app,
      url:                  "http://#{Barong.config.selenium_host}:#{Barong.config.selenium_port}/wd/hub",
      browser:              :remote,
      desired_capabilities: :chrome
  end

  Capybara.app_host   = "http://#{Barong.config.test_app_host}:#{Barong.config.test_app_port}"
  Capybara.run_server = false

  RSpec.configure do |config|
    config.before :each, type: :feature do
      Capybara.current_session.driver.browser.manage.window.resize_to(*screen_size)
    end
  end
else
  Capybara.register_driver :chrome do |app|
    headless = !Barong.config['chrome_headless'].in?(%w[ 0 false ])
    debug    = Barong.config['chrome_debug'].in?(%w[ 1 true ])

    driver_options = { args: [] }
    driver_options[:args] << '--log-path=' + Rails.root.join('log/chromedriver.log').to_s
    driver_options[:args] << '--verbose' if debug

    browser_options = Selenium::WebDriver::Chrome::Options.new
    browser_options.args << '--headless' if headless
    browser_options.args << '--disable-gpu'
    browser_options.args << '--ignore-certificate-errors'
    browser_options.args << '--disable-popup-blocking'
    browser_options.args << '--window-size=' + screen_size.join('x')
    browser_options.args << '--disable-extensions'

    Capybara::Selenium::Driver.new app, \
      browser:     :chrome,
      options:     browser_options,
      driver_opts: driver_options
  end
end

Capybara.default_driver        = :chrome
Capybara.javascript_driver     = :chrome
Capybara.default_max_wait_time = 5
