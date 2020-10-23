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
puts 'Phone creating'
puts '---------------------------'
Benchmark.bm do |x|
  # Creates 1 phone
  x.report(:p_1) {
    phone = Phone.new(user_id: user.id, country: 'UA', number: '123123123')
    phone.save(validate: false)
  }
  # Creates 1000 phones
  x.report(:p_1000) {
    1_000.times do
      phone = Phone.new(user_id: user.id, country: 'UA', number: '123123123')
      phone.save(validate: false)
    end
  }
end

puts '---------------------------'
puts 'Descrypts data from phone'
puts '---------------------------'
Benchmark.bm do |x|
  # Descrypts 1 phone
  x.report(:p_1) {
    Phone.last.number
  }
  # Descrypts 1000 phones
  x.report(:p_1000) {
    Phone.where(user_id: user.id).limit(1000).each do |phone|
      phone.number
    end
  }
end

## After benchmark
Phone.where(user_id: user.id).delete_all
user.destroy
