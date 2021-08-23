# frozen_string_literal: true

set :rails_env, :staging
set :disallow_pushing, false

set :application, -> { 'barong-' + fetch(:stage).to_s }

server '87.98.150.101',
  user: fetch(:user),
  port: '22',
  roles: %w[app db].freeze,
  ssh_options: { forward_agent: true }
