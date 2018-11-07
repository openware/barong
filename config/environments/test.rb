Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  config.log_level = :fatal
  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory
  config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr
  ENV['EVENT_API_JWT_PRIVATE_KEY'] = 'LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcFFJQkFBS0NBUUVBMmxVUEJWVXkyeVdhNS85bmYyazN2SEZoNUY5Wjk5d2g3Q2FNU2dtK1A0cndsUERWCk9pZTZmdGsxY1FpM3R0bGdnOW10Z2J5UkNyZmNxZk1wTHF5TkE1aVZUZDlZTzdoU1crOXd2eG81RDFwVzRrc1oKeVZUc3plZDRmTGg5Z0ptSE0zd3BEdFkyZGZ3c3BidkRyM09TUEpFakxHVE5oR0ZDSmlTNDRTNmY1aytoSFFJMApoZkNHclNPVVI5N1ZwU0pNS2FDekdacmR4OUhsWDArYjhZdzFPcFNsa2IzblIvQituZWhPYzNXNm5QYTMyYzZiCnBZRi9mWmJ4SERNSmIzczZEYUxERzFTbmhqb0plVHo2SWg3Q2Qrc0NYWUl5Z2VHVE9sQ2dnNC9uZFRzSVN1dlAKS3ptdjFadDljWDhXV2VZQ3daRTFBOVpBOUZ3dC9nVXljZUpOMHdJREFRQUJBb0lCQUNxNXhJTzlwWU1mTzg0MAp1L05DQ3VjMHBQeUU4RjFCMWQyWnVaQnZrYXhycXlMcWNqKzhNSkhNUGRvTjQ2M0RvbENMRTVvMDVZbGNhN0ZTClpYZTl5cWF1Z0dGSjJNRnZFNmJzRjNzK1RYWkVyb1lBUGw2WTRQSjJYcXpCaWNYVnhaQjh0cWd4b1Z5N2FaMVIKUGowaWQ3YWtqR2FPbjIxTmZ4MXB5RWhBMElmSUp1eWMvQ2FpNk9iL1IvNkxXb1pDNXBjV2VzRlMyN3dkeHpNOQpGQm9YUnVWclE3c3hWNUl1WS9sc2EwQ1VTNUVLMWdxZDRobDRENXUrMG4wMElYQTk1QTE4QjhaNUhER0Y1T2QrCjN2MnJqTmVNaHNrZmdDZW5WN084NXhob1haeVYxSiswWGY1SDh3eFF6U1ZLa1BMVlVhSWJOdkMyMXhWRWkycWQKeHh6RVV4a0NnWUVBNzA0Z0VaNzNUUHIwbG1iZWVpTUJSRlhNZ2pKdWtlWWpKaFZvZWZwV1dydXhaRkxsR3E3WgpLdXlMcEQyMUc0akJLVThnZWc1N1lsaGQxUFBPS0dweUtsVHliYlo5TjU5TGFLSEw2Z3QyMUt1aFV3Q1Yya3cwCkw3RW5DbDgvRFBhRDhZa2llS0I1MjMyQVNZVEpVbHVrK09tbUdvSzM1NDE5T1FwV2M2QTJ6WVVDZ1lFQTZaQmUKQk9Od2NSYjJpc21GTWxZZ1gvU2ZtTTNVaSsvZFdaRW9lbTN6YkdxdkYvODFycm5UOUpVUndmYXZSYm9KaW9WQQpsMERLQW5zNSs4enJtbDdHQnNWN2JvUElqWWdUWGpRMGVMR0FzZjRwdlo5RWxpOS8yY05saUdIdElMMGYzQzVCCk90enpMcjRIdTB4amo3VVNWeCs5dXpFam4zdVpEMGI1M1RWeVFYY0NnWUVBbWdsVzJTRFRIS2taRVVyc0FBQlMKUzNOUzdhZWF4cTAxaU1rVTlCY3d5THl5UmRxYUFGLzJDQXcxSXFaWjBueG5vYmgrTmpMbU52cWNnM3ZnQXVIcAoxTmZUS00zanNnOEdValo3ZEk2bWtlUmNObnBVK3l3OEYwclh6M1JadUhWaG52TGZ6bmUxbUpRakpLK2xpeTdVCmRTaW9zNzNhdE9DOWJ4NzVZUG9LN0tVQ2dZRUEzeWRvTFJPQkl3dmxrc1RuMWlnajFvcEswaHdXcjMwRjU4V2cKL3hoK00xL2EydnFqdDhVa2xkSzNuTEtzMDluanM4Mk00UGF1QzZEZ3pZd0Vyd0ZPQXJvOExHTU5BdXk0VkpGYwpjTlJuT2FpMUNNOWJJSU5SakNYOHBFbXIzbFBVVlBKOHNGamFvQlpBSE52blpDNkV6MmtzUmVXMU8zTkQwaXptCkhrd3FWaEVDZ1lFQXFKbDdsVUlML1QzM0JyWmFTSmJ3WTdzaDh3bmlyeDcyYUw1TFI3RUVVNVFkQzNoT28vYlYKTTdtUnJCalB1ZGpmMXRHZ1pHWGxqSFR5cUJqQjJBMHphdXQvbXk5UEE2K1p1WEV3ektLb2xlRXUvemQ2Zm41NwpMNlp2VXE3bXZtK0tXbDNQeUFPemhKamE1aVp1Tmc0eGJDNGdQWVRkN1NGbUdUZm52UjJLbXpjPQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=' 

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end
