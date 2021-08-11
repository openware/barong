# frozen_string_literal: true

set :rails_env, :staging

set :deploy_to, -> { "/home/#{fetch(:user)}/#{fetch(:stage)}/#{fetch(:application)}" }

server 'ex1.fr1.lgk.one',
  user: fetch(:user),
  port: '22',
  roles: %w[app db].freeze,
  ssh_options: { forward_agent: true }
