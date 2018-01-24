# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Account.create(role: "admin", email: "example@admin.com", password: "password") if Account.where(role: "admin").count == 0
Account.create(role: "member", email: "example@member.com", password: "password") if Account.where(role: "member").count == 0
