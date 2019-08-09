# frozen_string_literal: true

# To execute with optional user and api keys amount
# rake generate:users -- --n=1000

namespace 'generate' do
  desc 'Build Application container'
  task :users => :environment do
    ### Parse options
    options = {}

    o = OptionParser.new

    o.banner = 'Usage: rake generate:users [-n=100]'
    o.on('-n NUMBER', '--number NUMBER') { |num| options[:num] = num.to_i }

    args = o.order!(ARGV) {}
    o.parse!(args)

    options[:num] = 10 if options[:num].nil?
    result_arr = []

    options[:num].times do |i|
      email = Faker::Internet.email
      passwd = Faker::Internet.password(min_length: 10, special_characters: true)
      u = User.create(email: email, password: passwd, level: 3, state: 'active')

      api_key = APIKey.create(user_id: u.id, kid: SecureRandom.hex(8), algorithm: 'HS256')
      secret = SecureRandom.hex(16)
      SecretStorage.store_secret(secret, api_key.kid)
      result_arr.push({
        'uid' => u.uid,
        'email' => u.email,
        'password' => passwd,
        'kid' => api_key.kid,
        'secret' => secret
      })
    end

    File.write('tmp/payload.yml', result_arr.to_yaml)
  end
end
