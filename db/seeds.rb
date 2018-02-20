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

env_file = File.join(Rails.root, 'config', 'oauth_application.yml')
hash = YAML.load(File.open(env_file))

application = Doorkeeper::Application.new(autoauth: true, name: hash['oauth_app_name'], redirect_uri: hash['oauth_callback_url'], uid: hash['oauth_uid'], secret: hash['oauth_secret'])
application.save!

