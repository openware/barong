# frozen_string_literal: true

lock '3.16'

set :user, 'app'
set :application, 'barong'

set :roles, %w[app db].freeze

set :repo_url, ENV.fetch('DEPLOY_REPO', `git remote -v | grep origin | head -1 | awk  '{ print $2 }'`) if ENV['USE_LOCAL_REPO'].nil?
set :keep_releases, 10

set :linked_files, %w[.env config/credentials.yml.enc]
set :linked_dirs, %w[log tmp/pids tmp/cache tmp/sockets secrets]
set :config_files, fetch(:linked_files)

set :deploy_to, -> { "/home/#{fetch(:user)}/#{fetch(:application)}" }

set :disallow_pushing, true

set :db_dump_extra_opts, '--force'

set :branch, ENV.fetch('BRANCH', 'main')
#  ask(:branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp })

set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip

set :conditionally_migrate, true # Only attempt migration if db/migrate changed - not related to Webpacker, but a nice thing

set :db_local_clean, false
set :db_remote_clean, true

set :app_version, SemVer.find.to_s
set :current_version, `git rev-parse HEAD`.strip

set :sentry_organization, ENV['SENTRY_ORGANIZATION']
set :sentry_release_version, -> { [fetch(:app_version), fetch(:current_version)].join('-') }

set :puma_init_active_record, true
set :puma_control_app, true
set :puma_threads, [4, 16]
set :puma_tag, fetch(:application)
set :puma_daemonize, false
set :puma_preload_app, false
set :puma_prune_bundler, true
set :puma_init_active_record, true
set :puma_workers, 0
set :puma_bind, %w(tcp://0.0.0.0:9201)
set :puma_start_task, 'systemd:puma:start'

set :assets_roles, []

set :init_system, :systemd

set :systemd_sidekiq_role, :app
set :systemd_sidekiq_instances, -> { %i[cron_job] }

set :systemd_amqp_daemon_role, :app
set :systemd_amqp_daemon_instances, -> { %i[withdraw_coin deposit_intention matching order_processor trade_executor influx_writer] }

before 'deploy:starting', 'sentry:validate_config'
after 'deploy:published', 'sentry:notice_deployment'

after 'deploy:publishing', 'systemd:puma:reload-or-restart'
after 'deploy:publishing', 'systemd:sidekiq:reload-or-restart'

if defined? Slackistrano
  Rake::Task['deploy:starting'].prerequisites.delete('slack:deploy:starting')
  set :slackistrano,
      klass: Slackistrano::CustomMessaging,
      channel: ENV['SLACKISTRANO_CHANNEL'],
      webhook: ENV['SLACKISTRANO_WEBHOOK']

  # best when 75px by 75px.
  set :slackistrano_thumb_url, 'https://bitzlato.com/wp-content/uploads/2020/12/logo.svg'
  set :slackistrano_footer_icon, 'https://github.githubassets.com/images/modules/logos_page/Octocat.png'
end

# Removed rake, bundle, gem
# Added rails.
# rake has its own dotenv requirement in Rakefile
set :dotenv_hook_commands, %w{rails ruby}

Capistrano::DSL.stages.each do |stage|
  after stage, 'dotenv:hook'
end
