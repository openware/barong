# frozen_string_literal: true

seed = YAML.load(File.open(Rails.root.join('config', 'seed.yml')))

if Account.find_by(email: seed['admin']['email']).nil?
  admin = Account.create(
    role: 'admin',
    email: seed['admin']['email'],
    password: ENV.fetch('ADMIN_PASSWORD', SecureRandom.hex(15))
  )

  # Confirm admin account
  admin.confirm
  admin.level_set(:identity)

  puts "Admin email: #{admin.email}"
  puts "Admin password: #{admin.password}"
else
  puts "Account #{seed['admin']['email']} already exists"
end

# Create applications from seed
seed['applications'].each do |params|
  next if Doorkeeper::Application.find_by(uid: params['uid']).present?
  app = Doorkeeper::Application.create(params)
  puts app.to_json
end
