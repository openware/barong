# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin_email = ENV.fetch('ADMIN_USER', 'admin@peatio.tech')
admin = Account.create(email: admin_email, password: 'P@ssword', role: 'admin', confirmed_at: Time.now)
p "ADMIN email: #{admin.email} pass: #{admin.password}"

if Rails.env != 'production'
  secret = 'ZVBLXPBPtwa7YCK5pa2MqkBKXXZQ3HLDuc2hDtWVNWDpbd4qYUMdReNEND6sbHUg'
  id = Doorkeeper::Application.last ? Doorkeeper::Application.last.id : 1
  Doorkeeper::Application.create( id:           id,
                                  name:         'TestClient',
                                  uid:          1,
                                  secret:       secret,
                                  redirect_uri: 'http://localhost:3000/oauth/callback')
end

