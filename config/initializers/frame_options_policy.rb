# frozen_string_literal: true

# allow to define custom (from rails default sameorigin) frame_options
Barong::App.define do |config|
  config.set(:frame_options, 'deny', values: %w[deny sameorigin])
end

# The X-Frame-Options HTTP response header can be used to indicate whether or not
# a browser should be allowed to render a page in a <frame>, <iframe>, <embed> or <object>.
# Sites can use this to avoid clickjacking attacks, by ensuring that their content is not embedded into other sites.
Rails.application.config.action_dispatch.default_headers['X-Frame-Options'] = Barong::App.config.frame_options.upcase
