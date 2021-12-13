# frozen_string_literal: true

set :stage, :production
set :rails_env, :production
fetch(:default_env)[:rails_env] = :production
set :puma_bind, %w(tcp://0.0.0.0:9201)

server ENV.fetch( 'PUMA_SERVER' ),
       user: fetch(:user),
       port: '22',
       roles: %w[app db].freeze,
       ssh_options: { forward_agent: true }

server ENV.fetch( 'MAILER_SERVER' ),
       user: fetch(:user),
       port: '22',
       roles: %w[mailer].freeze,
       ssh_options: { forward_agent: true }
