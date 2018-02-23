# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
admin_email = ENV.fetch('ADMIN_USER', 'admin@barong.io')

admin = Account.create(email: admin_email, password: SecureRandom.hex(20), level: 1, role: 'admin', confirmed_at: Time.now)

puts 'Admin credentials: %s' % [admin.password]

if File.exist?([Rails.root, '/config', '/seed.yml'].join)
  seed_file = File.join(Rails.root, 'config', 'seed.yml')
  seed = YAML.load(File.open(seed_file))

  app_seed = seed['oauth_application']
  application = Doorkeeper::Application.new(skipauth: true, name: app_seed['oauth_app_name'], redirect_uri: app_seed['oauth_callback_url'])
  application.save!
end

