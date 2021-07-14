namespace :jwt do
  desc 'Generate Baerer Authorize header'
  task generate_bearer: :environment do
     codec = Barong::JWT.new(key: Barong::App.config.keystore.private_key)
     payload = { uid: 1, email: 'user@example.com', role: :member, level: 3, state: :active }
     puts codec.encode payload
  end
end
