# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

seed_file =  File.join(Rails.root, 'config', 'seed.yml')

if File.exist?(seed_file)
  seed = YAML.load(File.open(seed_file))

  admin = Account.create(email: seed['admin']['email'], password: SecureRandom.hex(20), level: 1, role: 'admin', confirmed_at: Time.now)

  puts 'Admin credentials: %s' % [admin.password]

  # Create applications from seed
  seed['applications'].each do |app|
    result = Doorkeeper::Application.new(app)

    result.save!
    puts 'Name: %s' % [result.name]
    puts "Application ID: %s\nSecret: %s" % [result.uid, result.secret]
  end
else
  admin = Account.create(email: Barong.config.email.admin, password: SecureRandom.hex(20), level: 1, role: 'admin', confirmed_at: Time.now)

  puts 'Admin credentials: %s' % [admin.password]
end
