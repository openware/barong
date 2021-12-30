# frozen_string_literal: true

set :stage, :sandbox
set :rails_env, :sandbox
set :user, 'app'
set :deploy_to, -> { "/home/#{fetch(:user)}/#{fetch(:stage)}/#{fetch(:application)}" }

server ENV.fetch( 'SANDBOX_MAILER_SERVER' ),
       user: 'app',
       port: '22',
       roles: %w[mailer].freeze,
       ssh_options: { forward_agent: true }
