# frozen_string_literal: true

seed = YAML.load(File.open(Rails.root.join('config', 'seed.yml')))

if Account.find_by(email: seed['admin']['email']).nil?
  admin = Account.create(
    role: 'admin',
    email: seed['admin']['email'],
    password: ENV.fetch('ADMIN_PASSWORD', SecureRandom.hex(15))
  )

  # Confirm admin account
  admin.update(confirmed_at: Time.now)
  admin.level_set(:mail)

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

# Create level mappings from seed
seed['level_mappings'].each do |params|
  next if LevelMapping.exists?(params)
  LevelMapping.create!(params)
end
