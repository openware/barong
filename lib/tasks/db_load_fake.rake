# frozen_string_literal: true

namespace :db do
  namespace :load do
    desc 'Creating the fake data'
    task fake: :environment do
      account = Account.create(email: 'admin@gmail.com', password: '123123', role: 'admin', confirmed_at: Faker::Time.between(2.days.ago, Date.today))
      Profile.create(account: account, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, country: Faker::Address.country)

      [*1..100].each do
        account = Account.create(email: Faker::Internet.email, password: Faker::Internet.password, confirmed_at: Faker::Time.between(2.days.ago, Date.today))
        states = %w[created pending approved rejected]
        profile = Profile.create(account: account, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, country: Faker::Address.country, state: states.sample)
        [*0..Faker::Number.between(0, 5)].each do |count|
          profile.documents.create(upload_id: Faker::Number.number(3), upload_filename: Faker::File.file_name, upload_content_size: Faker::Number.number(5) + ' bytes', upload_content_type: Faker::File.mime_type, doc_type: Faker::File.extension, doc_number: Faker::Number.number(4), doc_expire: Date.today + count.days)
        end
      end
      secret = 'ZVBLXPBPtwa7YCK5pa2MqkBKXXZQ3HLDuc2hDtWVNWDpbd4qYUMdReNEND6sbHUg'
      id = Doorkeeper::Application.last ? Doorkeeper::Application.last.id : 1
      Doorkeeper::Application.create(id: id, name: Faker::Name.name, uid: 1, secret: secret, redirect_uri: 'http://localhost:3000/oauth/callback')
    end
  end
end
