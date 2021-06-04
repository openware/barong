# frozen_string_literal: true

set :stage, :staging
set :rails_env, :staging
fetch(:default_env)[:rails_env] = :staging

server ENV.fetch( 'STAGING_SERVER' ), user: fetch(:user), roles: fetch(:roles)
