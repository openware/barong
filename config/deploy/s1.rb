# frozen_string_literal: true

set :user, 'app'

set :rails_env, :staging
set :disallow_pushing, false
set :application, -> { 'barong-' + fetch(:stage).to_s }
set :deploy_to, -> { "/home/#{fetch(:user)}/#{fetch(:stage)}/#{fetch(:application)}" }
set :puma_bind, -> { ["tcp://0.0.0.0:960#{fetch(:stage)[1].to_i || 9}", "unix://#{shared_path}/tmp/sockets/puma.sock"] }

server ENV.fetch('STAGING_SERVER'),
  user: fetch(:user),
  port: '22',
  roles: %w[app mailer db].freeze,
  ssh_options: { forward_agent: true }
