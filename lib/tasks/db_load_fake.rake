# frozen_string_literal: true

namespace :db do
  namespace :load do
    desc 'Creating the fake data'
    task fake: :environment do
      account = Account.create!(email: 'admin@gmail.com', password: 'Haepood8', role: 'admin', confirmed_at: Faker::Time.between(2.days.ago, Date.today))
      Profile.create!(account: account, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, country: Faker::Address.country, dob: Faker::Date.between(25.years.ago, 10.years.ago), address: Faker::Address.street_address, city: Faker::Address.city)

      compliance = Account.create!(email: 'compliance@gmail.com', password: 'Haepood8', role: 'compliance', confirmed_at: Faker::Time.between(2.days.ago, Date.today))
      Profile.create!(account: compliance, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, country: Faker::Address.country, dob: Faker::Date.between(25.years.ago, 10.years.ago), address: Faker::Address.street_address, city: Faker::Address.city)

      [*1..100].each do
        account = Account.create!(email: Faker::Internet.email, password: Faker::Internet.password, confirmed_at: Faker::Time.between(2.days.ago, Date.today))
        states = %w[created pending approved rejected]
        profile = Profile.create!(account: account, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, country: Faker::Address.country, state: states.sample, dob: Faker::Date.between(25.years.ago, 10.years.ago), address: Faker::Address.street_address, city: Faker::Address.city)

        [*0..Faker::Number.between(0, 2)].each do |count|
          profile.documents.create!(doc_type: Faker::File.extension, doc_number: Faker::Number.number(4), doc_expire: Date.today + count.days, upload: File.open('app/assets/images/background.jpg'))
        end
      end

      secret = 'ZVBLXPBPtwa7YCK5pa2MqkBKXXZQ3HLDuc2hDtWVNWDpbd4qYUMdReNEND6sbHUg'
      id = Doorkeeper::Application.last ? Doorkeeper::Application.last.id : 1
      Doorkeeper::Application.create!(id: id, name: Faker::Name.name, uid: 1, secret: secret, redirect_uri: 'http://localhost:3000/oauth/callback')
    end
  end
end
