# frozen_string_literal: true

set :user, 'app'
set :systemd_mailer_role, :app

set :rails_env, :staging
set :disallow_pushing, false
set :application, -> { 'barong-' + fetch(:stage).to_s }

set :deploy_to, -> { "/home/#{fetch(:user)}/#{fetch(:stage)}/#{fetch(:application)}" }

server '51.91.62.13',
  user: fetch(:user),
  port: '22',
  roles: %w[app db].freeze,
  ssh_options: { forward_agent: true }
