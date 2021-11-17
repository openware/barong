# frozen_string_literal: true

set :rails_env, :staging

set :application, -> { 'barong' }
set :deploy_to, -> { "/home/#{fetch(:user)}/#{fetch(:stage)}/#{fetch(:application)}" }

server '141.94.218.39',
  user: fetch(:user),
  port: '22',
  roles: %w[app db].freeze,
  ssh_options: { forward_agent: true }
