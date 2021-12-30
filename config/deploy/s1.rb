# frozen_string_literal: true

set :user, 'app'

set :rails_env, :staging
set :disallow_pushing, false
set :application, -> { 'barong-' + fetch(:stage).to_s }

set :deploy_to, -> { "/home/#{fetch(:user)}/#{fetch(:stage)}/#{fetch(:application)}" }

server ENV.fetch('STAGING_SERVER'),
  user: fetch(:user),
  port: '22',
  roles: %w[app mailer db].freeze,
  ssh_options: { forward_agent: true }
