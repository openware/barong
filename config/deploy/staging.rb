# frozen_string_literal: true

set :stage, :staging
set :rails_env, :staging
fetch(:default_env)[:rails_env] = :staging

server ENV['STAGING_SERVER'],
       user: fetch(:user),
       port: '22',
       roles: %w[app db].freeze,
       ssh_options: { forward_agent: true }
