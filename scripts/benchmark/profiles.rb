require 'benchmark'
require_relative "../../config/environment"

# Check only Error logs
ActiveRecord::Base.logger.level = 3

## Before benchmark
user = User.find_or_create_by(uid: "UIDExample", email: 'test_example@gmail.com') do |u|
  u.password = "PasswordExample12"
end

# Benchmark
puts '---------------------------'
puts 'Profile creating'
puts '---------------------------'
Benchmark.bm do |x|
  # Creates 1 profile
  x.report(:p_1) {
    Profile.create!(user_id: user.id, first_name: 'first_name', last_name: 'last_name',
                    address: 'address', dob: Time.now.to_date, state: 'verified')
  }
  # Creates 1000 profiles
  x.report(:p_1000) {
    1_000.times do
      Profile.create!(user_id: user.id, first_name: 'first_name', last_name: 'last_name',
                      address: 'address', dob: Time.now.to_date, state: 'verified')
    end
  }
end

puts '---------------------------'
puts 'Descrypts data from profile'
puts '---------------------------'
Benchmark.bm do |x|
  # Descrypts 1 profile
  x.report(:p_1) {
    Profile.last.first_name
    Profile.last.last_name
    Profile.last.address
    Profile.last.dob
  }
  # Descrypts 1000 profiles
  x.report(:p_1000) {
    Profile.where(user_id: user.id).limit(1000).each do |profile|
      profile.first_name
      profile.last_name
      profile.address
      profile.dob
    end
  }
end

## After benchmark
Profile.where(user_id: user.id).delete_all
user.destroy
